import Component from '@glimmer/component';
import { service } from '@ember/service';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { Input } from '@ember/component';
import { fn, get } from '@ember/helper';
import eq from 'ember-truth-helpers/helpers/eq';
import add from 'ember-math-helpers/helpers/add';
import div_ from 'ember-math-helpers/helpers/div';
import JsonDisplay from '../blueprint/json-display.gjs';
import gt from 'ember-truth-helpers/helpers/gt';
import not from 'ember-truth-helpers/helpers/not';

export default class TypesListTableFindDuplicatesComponent extends Component {
  @service colormodes;
  @service type;
  @service store;

  // Fields the user has toggled on for comparison
  @tracked selectedFields = [];

  // Results: array of groups, each group is an array of snapshot plain objects
  @tracked duplicateGroups = [];

  // Whether the scan has been run at least once
  @tracked hasScanned = false;

  // Whether a scan is in progress
  @tracked scanning = false;

  // ID of the record whose JSON detail panel is currently open (null = none)
  @tracked expandedRecordId = null;

  // Pagination
  @tracked currentPage = 0;
  pageSize = 5;

  // ─── Derived helpers ───────────────────────────────────────────────────────

  // Modules worth comparing: skip file uploaders, editorjs blobs, and arrays
  get comparableModules() {
    const current = this.type.currentType;
    if (!current || !current.modules) return [];

    return current.modules.filter((m) => {
      return (
        m.input_type !== 'file_uploader' &&
        m.input_type !== 'editorjs' &&
        m.var_type !== 'array' &&
        m.input_slug !== 'updated_on' &&
        m.input_slug !== 'created_on'
      );
    });
  }

  get totalDuplicateObjects() {
    return this.duplicateGroups.reduce((sum, group) => sum + group.length, 0);
  }

  get totalPages() {
    return Math.ceil(this.duplicateGroups.length / this.pageSize);
  }

  get paginatedGroups() {
    const start = this.currentPage * this.pageSize;
    return this.duplicateGroups.slice(start, start + this.pageSize);
  }

  get paginatedGroupOffset() {
    return this.currentPage * this.pageSize;
  }

  get hasPrevPage() {
    return this.currentPage > 0;
  }

  get hasNextPage() {
    return this.currentPage < this.totalPages - 1;
  }

  get noDuplicatesFound() {
    return this.hasScanned && this.duplicateGroups.length === 0;
  }

  get detailColspan() {
    return this.selectedFields.length + 2;
  }

  // ─── Field selection ───────────────────────────────────────────────────────

  isFieldSelected = (slug) => {
    return this.selectedFields.includes(slug);
  };

  @action
  toggleField(slug) {
    if (this.selectedFields.includes(slug)) {
      this.selectedFields = this.selectedFields.filter((f) => f !== slug);
    } else {
      this.selectedFields = [...this.selectedFields, slug];
    }
    // Clear previous results when selection changes
    this.hasScanned = false;
    this.duplicateGroups = [];
    this.currentPage = 0;
  }

  @action
  selectAllFields() {
    this.selectedFields = this.comparableModules.map((m) => m.input_slug);
    this.hasScanned = false;
    this.duplicateGroups = [];
    this.currentPage = 0;
  }

  @action
  clearAllFields() {
    this.selectedFields = [];
    this.hasScanned = false;
    this.duplicateGroups = [];
    this.currentPage = 0;
  }

  // ─── Scan ──────────────────────────────────────────────────────────────────

  @action
  async runScan() {
    if (this.selectedFields.length === 0) return;

    this.scanning = true;
    this.duplicateGroups = [];
    this.hasScanned = false;

    // Fetch every record for the current type.
    // types.js registers dynamic models with underscores converted to hyphens,
    // so we must use the same form when querying the store.
    const modelName = this.type.currentType.slug.replace(/_/g, '-');
    const allRecords = await this.store.query(modelName, {
      sort: '-id',
      show_public_objects_only: false,
      page: { limit: -1, offset: 0 },
    });

    // Snapshot each record as a plain object immediately after the fetch.
    // Storing live Ember Data proxies in @tracked state causes Glimmer to
    // re-invalidate on every render pass, hanging the browser.
    const snapshots = allRecords.map((record) => ({
      id: record.id,
      modules: Object.assign({}, record.modules),
      _record: record, // kept only for destroyRecord(); never read in template
    }));

    // Build a fingerprint for each snapshot using only the selected fields
    const groups = new Map();

    snapshots.forEach((snap) => {
      const fingerprint = this.selectedFields
        .map((slug) => {
          const val = snap.modules[slug];
          if (val === null || val === undefined) return '';
          if (typeof val === 'object') return JSON.stringify(val);
          return String(val).trim().toLowerCase();
        })
        .join('|||');

      if (!groups.has(fingerprint)) {
        groups.set(fingerprint, []);
      }
      groups.get(fingerprint).push(snap);
    });

    // Keep only groups with more than one record
    const dupes = [];
    groups.forEach((snaps) => {
      if (snaps.length > 1) {
        dupes.push(snaps);
      }
    });

    // Sort groups largest first
    dupes.sort((a, b) => b.length - a.length);

    this.duplicateGroups = dupes;
    this.hasScanned = true;
    this.scanning = false;
    this.currentPage = 0;
  }

  // ─── Detail panel toggle ──────────────────────────────────────────────────

  @action
  toggleDetails(recordId) {
    this.expandedRecordId =
      this.expandedRecordId === recordId ? null : recordId;
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  @action
  async deleteRecord(snap) {
    const confirmed = window.confirm(
      `Delete record "${snap.id}"? This cannot be undone.`,
    );
    if (!confirmed) return;

    await snap._record.destroyRecord();

    // Remove the deleted snapshot from every group; drop groups that become
    // singletons or empty
    this.duplicateGroups = this.duplicateGroups
      .map((group) => group.filter((s) => s.id !== snap.id))
      .filter((group) => group.length > 1);

    // Close detail panel if it was open for the deleted record
    if (this.expandedRecordId === snap.id) {
      this.expandedRecordId = null;
    }
  }

  // ─── Pagination ────────────────────────────────────────────────────────────

  @action
  prevPage() {
    if (this.hasPrevPage) this.currentPage -= 1;
  }

  @action
  nextPage() {
    if (this.hasNextPage) this.currentPage += 1;
  }

  // ─── Reset when modal closes ───────────────────────────────────────────────

  @action
  reset() {
    this.selectedFields = [];
    this.duplicateGroups = [];
    this.hasScanned = false;
    this.scanning = false;
    this.expandedRecordId = null;
    this.currentPage = 0;
  }
  <template>
    {{! Modal }}
    <div
      class="modal fade"
      id="findDuplicatesModal"
      tabindex="-1"
      aria-labelledby="findDuplicatesModalLabel"
      aria-hidden="true"
      {{on "hidden.bs.modal" this.reset}}
    >
      <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content">

          <div class="modal-header">
            <h1
              class="modal-title fst-italic fs-5"
              id="findDuplicatesModalLabel"
            >
              Find Duplicates —
              <span
                class="text-capitalize"
              >{{this.type.currentType.plural}}</span>
            </h1>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>

          <div class="modal-body">

            {{! Step 1: Field picker }}
            <p class="text-muted mb-3">
              Select the fields to compare. Two records are considered
              duplicates when every selected field matches exactly.
            </p>

            <div class="d-flex align-items-center gap-2 mb-3">
              <button
                type="button"
                class="btn btn-outline-{{this.colormodes.inverseMode}} btn-sm"
                {{on "click" this.selectAllFields}}
              >Select all</button>
              <button
                type="button"
                class="btn btn-outline-{{this.colormodes.inverseMode}} btn-sm"
                {{on "click" this.clearAllFields}}
              >Clear</button>
            </div>

            {{! Field checkboxes }}
            <div class="row g-2 mb-4">
              {{#each this.comparableModules as |module|}}
                <div class="col-6 col-md-4 col-lg-3">
                  <div
                    class="form-check border p-2
                      {{if
                        (this.isFieldSelected module.input_slug)
                        'border-primary bg-primary bg-opacity-10'
                      }}"
                  >
                    <Input
                      class="form-check-input mx-1"
                      @type="checkbox"
                      @checked={{this.isFieldSelected module.input_slug}}
                      id="dup-field-{{module.input_slug}}"
                      {{on "change" (fn this.toggleField module.input_slug)}}
                    />
                    <label
                      class="form-check-label text-truncate d-block cursor-pointer"
                      for="dup-field-{{module.input_slug}}"
                    >
                      {{module.input_slug}}
                      {{#if module.input_primary}}
                        <i
                          class="fa-solid fa-star fa-xs text-warning ms-1"
                          title="Primary field"
                        ></i>
                      {{/if}}
                    </label>
                    <small class="text-muted mx-1">{{module.input_type}}</small>
                  </div>
                </div>
              {{else}}
                <div class="col-12">
                  <p class="text-muted fst-italic">No comparable fields found
                    for this track.</p>
                </div>
              {{/each}}
            </div>

            {{! Results area }}
            {{#if this.scanning}}
              <div class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Scanning…</span>
                </div>
                <p class="mt-3 text-muted">Scanning all records…</p>
              </div>

            {{else if this.noDuplicatesFound}}
              <div
                class="alert alert-success d-flex align-items-center gap-2"
                role="alert"
              >
                <i class="fa-solid fa-circle-check fa-lg"></i>
                <span>No duplicates found across
                  <strong>{{this.selectedFields.length}}</strong>
                  {{if (eq this.selectedFields.length 1) "field" "fields"}}.
                </span>
              </div>

            {{else if this.hasScanned}}
              <div
                class="alert alert-warning d-flex align-items-center gap-2 mb-3"
                role="alert"
              >
                <i class="fa-solid fa-triangle-exclamation fa-lg"></i>
                <span>
                  Found
                  <strong>{{this.duplicateGroups.length}}</strong>
                  duplicate
                  {{if (eq this.duplicateGroups.length 1) "group" "groups"}}
                  ({{this.totalDuplicateObjects}}
                  objects total). Use the eye icon to inspect a record, then the
                  trash icon to delete it one at a time.
                </span>
              </div>

              {{#each this.paginatedGroups as |group groupIndex|}}
                <div class="mb-3 border border-warning">
                  <div
                    class="px-3 py-2 bg-warning bg-opacity-10 d-flex justify-content-between align-items-center"
                  >
                    <span class="fw-semibold">
                      Group
                      {{add (add groupIndex this.paginatedGroupOffset) 1}}
                      <span
                        class="badge bg-warning text-dark ms-1"
                      >{{group.length}}
                        records</span>
                    </span>
                  </div>

                  <div class="overflow-hidden">
                    <table
                      class="table table-sm table-hover mb-0 types-data-table w-100"
                      style="table-layout: fixed;"
                    >
                      <colgroup>
                        <col style="width: 20%;" />
                        {{#each this.selectedFields as |_field|}}
                          <col
                            style="width: {{div_
                              60
                              this.selectedFields.length
                            }}%;"
                          />
                        {{/each}}
                        <col style="width: 20%;" />
                      </colgroup>
                      <thead>
                        <tr>
                          <th class="ps-3">ID</th>
                          {{#each this.selectedFields as |field|}}
                            <th class="text-truncate">{{field}}</th>
                          {{/each}}
                          <th></th>
                        </tr>
                      </thead>
                      <tbody>
                        {{#each group as |snap|}}
                          <tr>
                            <td class="ps-3" style="min-width: 0;">
                              <span
                                class="slug-ellipsis text-muted d-block text-truncate"
                              >{{snap.id}}</span>
                            </td>
                            {{#each this.selectedFields as |field|}}
                              <td style="min-width: 0;">
                                <span class="d-block text-truncate">
                                  {{#if (get snap.modules field)}}
                                    {{get snap.modules field}}
                                  {{else}}
                                    <span class="text-muted fst-italic">—</span>
                                  {{/if}}
                                </span>
                              </td>
                            {{/each}}
                            <td
                              class="text-end pe-2"
                              style="white-space: nowrap; width: 1%;"
                            >
                              <button
                                type="button"
                                class="btn btn-outline-{{this.colormodes.inverseMode}}
                                  btn-sm me-1"
                                title="{{if
                                  (eq this.expandedRecordId snap.id)
                                  'Collapse details'
                                  'View details'
                                }}"
                                {{on "click" (fn this.toggleDetails snap.id)}}
                              >
                                <i
                                  class="fa-solid
                                    {{if
                                      (eq this.expandedRecordId snap.id)
                                      'fa-eye-slash'
                                      'fa-eye'
                                    }}"
                                ></i>
                              </button>
                              <button
                                type="button"
                                class="btn btn-outline-danger btn-sm"
                                title="Delete record"
                                {{on "click" (fn this.deleteRecord snap)}}
                              ><i class="fa-solid fa-trash"></i></button>
                            </td>
                          </tr>
                          {{#if (eq this.expandedRecordId snap.id)}}
                            <tr>
                              <td
                                colspan={{this.detailColspan}}
                                class="p-0"
                                style="max-width: 0;"
                              >
                                <div
                                  class="p-3 bg-{{this.colormodes.mode}}
                                    border-top overflow-hidden"
                                >
                                  <p class="text-muted small mb-2 fw-semibold">
                                    modules.*
                                    <span class="text-muted fw-normal ms-2">ID:
                                      {{snap.id}}</span>
                                  </p>
                                  <div
                                    style="overflow-x: auto; max-width: 100%;"
                                  >
                                    <JsonDisplay @jsondata={{snap.modules}} />
                                  </div>
                                </div>
                              </td>
                            </tr>
                          {{/if}}
                        {{/each}}
                      </tbody>
                    </table>
                  </div>
                </div>
              {{/each}}

              {{! Pagination controls }}
              {{#if (gt this.totalPages 1)}}
                <div
                  class="d-flex align-items-center justify-content-between mt-2 mb-1"
                >
                  <button
                    type="button"
                    class="btn btn-outline-{{this.colormodes.inverseMode}}
                      btn-sm"
                    disabled={{not this.hasPrevPage}}
                    {{on "click" this.prevPage}}
                  >
                    <i class="fa-solid fa-chevron-left me-1"></i>Previous
                  </button>
                  <span class="text-muted small">
                    Page
                    {{add this.currentPage 1}}
                    of
                    {{this.totalPages}}
                    <span
                      class="ms-2 text-muted"
                    >({{this.duplicateGroups.length}} groups total)</span>
                  </span>
                  <button
                    type="button"
                    class="btn btn-outline-{{this.colormodes.inverseMode}}
                      btn-sm"
                    disabled={{not this.hasNextPage}}
                    {{on "click" this.nextPage}}
                  >
                    Next<i class="fa-solid fa-chevron-right ms-1"></i>
                  </button>
                </div>
              {{/if}}
            {{/if}}

          </div>{{! /modal-body }}

          <div
            class="modal-footer d-flex align-items-center justify-content-between p-0"
          >
            <div class="d-flex align-items-center justify-content-start">
              <button
                type="button"
                class="btn btn-outline-secondary btn-sm me-2"
                data-bs-dismiss="modal"
              >Close</button>
            </div>

            <div class="d-flex align-items-center justify-content-end">
              <button
                type="button"
                class="btn btn-primary ms-2
                  {{if (eq this.selectedFields.length 0) 'disabled'}}"
                {{on "click" this.runScan}}
                disabled={{eq this.selectedFields.length 0}}
              >
                {{#if this.scanning}}
                  <span
                    class="spinner-border spinner-border-sm me-1"
                    role="status"
                  ></span>
                  Scanning…
                {{else}}
                  <i class="fa-solid fa-magnifying-glass me-1"></i>
                  Find Duplicates
                {{/if}}
              </button>
            </div>
          </div>

        </div>
      </div>
    </div>
  </template>
}
