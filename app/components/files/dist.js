import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import ENV from 'junction/config/environment';

export default class FilesDistComponent extends Component {
  @service colormodes;

  // ── Target ───────────────────────────────────────────────────────────────
  // 'dist' → uploads/sites/dist   |   'dist-php' → uploads/sites/dist-php
  @tracked target = 'dist';

  // ── UI state ─────────────────────────────────────────────────────────────
  @tracked isDragging = false;
  @tracked isUploading = false;
  @tracked uploadProgress = 0;
  @tracked deployedOk = false;
  @tracked errorMessage = null;
  @tracked versions = [];
  @tracked isLoadingVersions = false;
  @tracked isReverting = false;

  get apiBase() {
    return ENV.TribeENV.API_URL + '/uploads.php';
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  constructor(owner, args) {
    super(owner, args);
    this.loadVersions();
  }

  // ── Target switcher ──────────────────────────────────────────────────────

  @action
  setTarget(t) {
    if (this.target === t) return;
    this.target = t;
    this.deployedOk = false;
    this.errorMessage = null;
    this.versions = [];
    this.loadVersions();
  }

  // ── Version list ─────────────────────────────────────────────────────────

  @action
  async loadVersions() {
    this.isLoadingVersions = true;
    try {
      const res = await fetch(
        `${this.apiBase}?action=dist_versions&target=${this.target}`,
      );
      const data = await res.json();
      if (data.status === 'success') this.versions = data.versions ?? [];
      this.isLoadingVersions = false;
    } catch {
      this.isLoadingVersions = false;
      // silently ignore – versions list is optional
    } finally {
      this.isLoadingVersions = false;
    }
  }

  // ── Drag & drop handlers ──────────────────────────────────────────────────

  @action
  onDragOver(event) {
    event.preventDefault();
    this.isDragging = true;
  }

  @action
  onDragLeave() {
    this.isDragging = false;
  }

  @action
  async onDrop(event) {
    event.preventDefault();
    this.isDragging = false;

    const items = event.dataTransfer?.items;
    if (!items) return;

    // Collect all DataTransferItems into FileSystem entries
    const entries = [];
    for (const item of items) {
      if (item.kind !== 'file') continue;
      const entry = item.webkitGetAsEntry?.();
      if (entry) {
        entries.push(entry);
      } else {
        const file = item.getAsFile();
        if (file) {
          this.uploadZip(file);
          return;
        }
      }
    }

    if (!entries.length) return;

    // Single zip file dropped
    if (
      entries.length === 1 &&
      entries[0].isFile &&
      entries[0].name.toLowerCase().endsWith('.zip')
    ) {
      const file = await this._entryToFile(entries[0]);
      this.uploadZip(file);
      return;
    }

    // Folder or multi-file drop → folder upload
    const { files, paths } = await this._collectEntries(entries);
    if (files.length) this.uploadFolder(files, paths);
  }

  // ── File/folder input triggers ────────────────────────────────────────────

  @action
  triggerSelectZip() {
    document.getElementById('dist-zip-input')?.click();
  }

  @action
  triggerSelectFolder() {
    document.getElementById('dist-folder-input')?.click();
  }

  @action
  onZipSelected(event) {
    const file = event.target.files?.[0];
    if (file) this.uploadZip(file);
    event.target.value = '';
  }

  @action
  onFolderSelected(event) {
    const fileList = event.target.files;
    if (!fileList?.length) return;

    const files = [];
    const paths = [];
    for (const f of fileList) {
      files.push(f);
      paths.push(f.webkitRelativePath || f.name);
    }
    this.uploadFolder(files, paths);
    event.target.value = '';
  }

  // ── Upload: zip ───────────────────────────────────────────────────────────

  async uploadZip(file) {
    this.isUploading = true;
    this.uploadProgress = 0;
    this.deployedOk = false;
    this.errorMessage = null;

    const formData = new FormData();
    formData.append('file', file);

    await this._sendWithProgress(
      `${this.apiBase}?action=dist_upload&target=${this.target}`,
      formData,
    );
  }

  // ── Upload: folder ────────────────────────────────────────────────────────

  async uploadFolder(files, paths) {
    this.isUploading = true;
    this.uploadProgress = 0;
    this.deployedOk = false;
    this.errorMessage = null;

    const formData = new FormData();
    files.forEach((f, i) => {
      formData.append('files[]', f);
      formData.append('paths[]', paths[i] ?? f.name);
    });

    await this._sendWithProgress(
      `${this.apiBase}?action=dist_upload&target=${this.target}`,
      formData,
    );
  }

  // ── Shared XHR sender ─────────────────────────────────────────────────────

  async _sendWithProgress(url, formData) {
    try {
      await new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();

        xhr.upload.addEventListener('progress', (e) => {
          if (e.lengthComputable) {
            this.uploadProgress = Math.round((e.loaded / e.total) * 100);
          }
        });

        xhr.addEventListener('load', () => {
          try {
            const data = JSON.parse(xhr.responseText);
            if (data.status === 'success') {
              this.deployedOk = true;
              this.versions = data.versions ?? [];
            } else {
              this.errorMessage = data.error_message ?? 'Deployment failed.';
            }
          } catch {
            this.errorMessage = 'Invalid server response.';
          }
          resolve();
        });

        xhr.addEventListener('error', () => {
          this.errorMessage = 'Network error during upload.';
          reject();
        });

        xhr.open('POST', url);
        xhr.send(formData);
      });
    } finally {
      this.isUploading = false;
    }
  }

  // ── Revert ────────────────────────────────────────────────────────────────

  @action
  async revertToVersion(timestamp) {
    if (!confirm(`Revert live ${this.target} to version ${timestamp}?`)) return;

    this.isReverting = true;
    this.errorMessage = null;

    try {
      const formData = new FormData();
      formData.append('action', 'dist_revert');
      formData.append('timestamp', timestamp);
      formData.append('target', this.target);

      const res = await fetch(this.apiBase, { method: 'POST', body: formData });
      const data = await res.json();

      if (data.status === 'success') {
        this.versions = data.versions ?? [];
        this.deployedOk = true;
      } else {
        this.errorMessage = data.error_message ?? 'Revert failed.';
      }
    } catch {
      this.errorMessage = 'Network error during revert.';
    } finally {
      this.isReverting = false;
    }
  }

  // ── Reset UI ──────────────────────────────────────────────────────────────

  @action
  reset() {
    this.deployedOk = false;
    this.errorMessage = null;
    this.uploadProgress = 0;
  }

  // ── FileSystem Entry helpers (for drag-and-drop folders) ──────────────────

  _entryToFile(entry) {
    return new Promise((res, rej) => entry.file(res, rej));
  }

  async _collectEntries(entries) {
    const files = [];
    const paths = [];

    const walk = async (entry, prefix = '') => {
      if (entry.isFile) {
        const file = await this._entryToFile(entry);
        files.push(file);
        paths.push(prefix + entry.name);
      } else if (entry.isDirectory) {
        const reader = entry.createReader();
        const children = await new Promise((res, rej) =>
          reader.readEntries(res, rej),
        );
        for (const child of children) {
          await walk(child, prefix + entry.name + '/');
        }
      }
    };

    for (const e of entries) await walk(e);
    return { files, paths };
  }
}
