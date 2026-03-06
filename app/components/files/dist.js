import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import ENV from 'junction/config/environment';

export default class FilesDistComponent extends Component {
  @service colormodes;

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

  // ── Version list ─────────────────────────────────────────────────────────

  @action
  async loadVersions() {
    this.isLoadingVersions = true;
    try {
      const res = await fetch(this.apiBase + '?action=dist_versions');
      const data = await res.json();
      if (data.status === 'success') this.versions = data.versions ?? [];
    } catch (e) {
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
  onDrop(event) {
    event.preventDefault();
    this.isDragging = false;

    const items = event.dataTransfer?.items;
    if (!items) return;

    for (const item of items) {
      if (item.kind === 'file') {
        const file = item.getAsFile();
        if (file) {
          this.uploadZip(file);
          return;
        }
      }
    }
  }

  @action
  triggerSelectFile() {
    document.getElementById('dist-zip-input')?.click();
  }

  @action
  onFileSelected(event) {
    const file = event.target.files?.[0];
    if (file) this.uploadZip(file);
    event.target.value = '';
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  async uploadZip(file) {
    this.isUploading = true;
    this.uploadProgress = 0;
    this.deployedOk = false;
    this.errorMessage = null;

    const formData = new FormData();
    formData.append('file', file);

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

        xhr.open('POST', this.apiBase + '?action=dist_upload');
        xhr.send(formData);
      });
    } finally {
      this.isUploading = false;
    }
  }

  // ── Revert ────────────────────────────────────────────────────────────────

  @action
  async revertToVersion(timestamp) {
    if (!confirm('Revert live dist to version ' + timestamp + '?')) return;

    this.isReverting = true;
    this.errorMessage = null;

    try {
      const formData = new FormData();
      formData.append('action', 'dist_revert');
      formData.append('timestamp', timestamp);

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
}
