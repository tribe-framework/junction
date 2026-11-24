import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import ENV from 'junction/config/environment';
import { on } from '@ember/modifier';
import eq from 'ember-truth-helpers/helpers/eq';
import { fn } from '@ember/helper';
import or from 'ember-truth-helpers/helpers/or';

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
  <template>
    <div class="row mt-3 row-cols-1 g-3 mx-0">
      <div class="card px-0 mx-0 border-0">
        <div class="card-body p-0">

          {{! ── Hidden inputs ── }}
          <input
            type="file"
            id="dist-zip-input"
            accept=".zip"
            class="d-none"
            {{on "change" this.onZipSelected}}
          />
          <input
            type="file"
            id="dist-folder-input"
            class="d-none"
            webkitdirectory
            multiple
            {{on "change" this.onFolderSelected}}
          />

          {{! ── Target selector ── }}
          <div
            class="btn-group w-100 mb-3"
            role="group"
            aria-label="Deployment target"
          >
            <button
              type="button"
              class="btn btn-sm
                {{if
                  (eq this.target 'dist')
                  'btn-primary'
                  'btn-outline-primary'
                }}"
              {{on "click" (fn this.setTarget "dist")}}
            >
              <i class="fa-brands fa-html5"></i>&nbsp;dist
              <span class="opacity-50 ms-1 small">/uploads/sites/dist</span>
            </button>
            <button
              type="button"
              class="btn btn-sm
                {{if
                  (eq this.target 'dist-php')
                  'btn-primary'
                  'btn-outline-primary'
                }}"
              {{on "click" (fn this.setTarget "dist-php")}}
            >
              <i class="fa-brands fa-php"></i>&nbsp;dist-php
              <span class="opacity-50 ms-1 small">/uploads/sites/dist-php</span>
            </button>
          </div>

          {{! ── Drop zone ── }}
          {{#if this.isUploading}}
            <div
              class="text-center text-{{this.colormodes.inverseMode}}
                w-100 fs-4 p-5"
              style="border: 2px dashed #eee;"
            >
              <i class="fa-solid fa-rocket fa-spin"></i>&nbsp;Deploying to
              <strong>{{this.target}}</strong>… ({{this.uploadProgress}}%)
              <div
                class="progress mt-3"
                role="progressbar"
                aria-valuenow="{{this.uploadProgress}}"
                aria-valuemin="0"
                aria-valuemax="100"
              >
                <div
                  class="progress-bar progress-bar-striped progress-bar-animated"
                  style="width: {{this.uploadProgress}}%"
                ></div>
              </div>
            </div>

          {{else if this.deployedOk}}
            <div
              class="text-center w-100 fs-5 p-4"
              style="border: 2px solid #eee;"
            >
              <div class="text-success mb-2">
                <i class="fa-solid fa-circle-check"></i>&nbsp;Deployed
                successfully to
                <strong>{{this.target}}</strong>
              </div>
              <button
                type="button"
                class="btn btn-outline-secondary btn-sm"
                {{on "click" this.reset}}
              >
                <i class="fa-solid fa-cloud-arrow-up"></i>&nbsp;Deploy another
                build
              </button>
            </div>

          {{else if this.errorMessage}}
            <div
              class="text-center w-100 fs-5 p-4"
              style="border: 2px dashed #dc3545;"
            >
              <div class="text-danger mb-2">
                <i
                  class="fa-solid fa-circle-xmark"
                ></i>&nbsp;{{this.errorMessage}}
              </div>
              <button
                type="button"
                class="btn btn-outline-secondary btn-sm"
                {{on "click" this.reset}}
              >
                <i class="fa-solid fa-rotate-left"></i>&nbsp;Try again
              </button>
            </div>

          {{else}}
            {{! ── Idle drop zone ── }}
            <div
              class="text-center w-100 fs-5 p-5
                {{if this.isDragging 'text-primary' 'text-muted'}}"
              style="border: 2px dashed {{if
                this.isDragging
                '#0d6efd'
                '#eee'
              }}; cursor: pointer;"
              role="button"
              {{on "dragover" this.onDragOver}}
              {{on "dragleave" this.onDragLeave}}
              {{on "drop" this.onDrop}}
            >
              {{#if this.isDragging}}
                <div class="fs-4">
                  <i
                    class="fa-solid fa-wand-magic-sparkles fa-spin"
                  ></i>&nbsp;Drop to deploy to
                  <strong>{{this.target}}</strong>
                </div>
              {{else}}
                <div class="fs-4 mb-3">
                  <i class="fa-solid fa-cloud-arrow-up"></i>&nbsp;Drop a folder
                  or
                  <code>.zip</code>
                  here
                </div>
                <div
                  class="d-flex align-items-center justify-content-center gap-2 flex-wrap"
                >
                  <button
                    type="button"
                    class="btn btn-outline-secondary btn-sm"
                    {{on "click" this.triggerSelectZip}}
                  >
                    <i class="fa-solid fa-file-zipper"></i>&nbsp;Select zip file
                  </button>
                  <span class="text-muted small">or</span>
                  <button
                    type="button"
                    class="btn btn-outline-secondary btn-sm"
                    {{on "click" this.triggerSelectFolder}}
                  >
                    <i class="fa-solid fa-folder-open"></i>&nbsp;Select folder
                  </button>
                </div>
                <div class="fs-6 text-muted mt-3">
                  Deploying to
                  <strong class="text-body">{{this.target}}</strong>
                  — the current live folder is backed up automatically
                </div>
              {{/if}}
            </div>
          {{/if}}

        </div>
      </div>

      {{! ── Version history ── }}
      {{#if (or this.versions.length this.isLoadingVersions)}}
        <div class="card px-0 mx-0 border-0 mt-2">
          <div
            class="card-header px-0 bg-transparent border-bottom d-flex align-items-center justify-content-between"
          >
            <span class="fs-6 fw-semibold">
              <i class="fa-solid fa-clock-rotate-left"></i>&nbsp;Previous
              versions of
              <strong>{{this.target}}</strong>
              (up to 7)
            </span>
            <button
              type="button"
              class="btn btn-link btn-sm p-0 text-muted"
              {{on "click" this.loadVersions}}
            >
              {{#if this.isLoadingVersions}}
                <i class="fa-solid fa-arrows-rotate fa-spin"></i>
              {{else}}
                <i class="fa-solid fa-arrows-rotate"></i>
              {{/if}}
            </button>
          </div>
          <div class="card-body px-0 pt-2 pb-0">
            {{#if this.isReverting}}
              <div class="text-muted small py-2"><i
                  class="fa-solid fa-spinner fa-spin"
                ></i>&nbsp;Reverting…</div>
            {{else}}
              {{#each this.versions as |v|}}
                <div
                  class="d-flex align-items-center justify-content-between py-1 border-bottom"
                >
                  <span
                    class="small text-muted font-monospace"
                  >{{v.label}}</span>
                  <button
                    type="button"
                    class="btn btn-outline-warning btn-sm py-0 px-2"
                    {{on "click" (fn this.revertToVersion v.timestamp)}}
                  >
                    <i class="fa-solid fa-rotate-left"></i>&nbsp;Revert
                  </button>
                </div>
              {{/each}}
            {{/if}}
          </div>
        </div>
      {{/if}}

    </div>
  </template>
}
