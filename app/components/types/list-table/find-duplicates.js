import Component from '@glimmer/component';
import { service } from '@ember/service';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

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
    this.expandedRecordId = this.expandedRecordId === recordId ? null : recordId;
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
}
