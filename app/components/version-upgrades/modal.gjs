import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import ENV from 'junction/config/environment';
import didInsert from '../../modifiers/did-insert.js';
import not from 'ember-truth-helpers/helpers/not';
import eq from 'ember-truth-helpers/helpers/eq';

export default class VersionUpgradesModalComponent extends Component {
  @tracked status = null;
  @tracked isLoading = false;
  @tracked runningAction = null;
  @tracked errorMessage = null;
  @tracked successMessage = null;
  @tracked log = '';
  @tracked reloadJunction = false;

  get endpoint() {
    return (ENV.TribeENV?.API_URL ?? '').replace(/\/+$/, '') + '/upgrades.php';
  }

  get isBusy() {
    return this.runningAction !== null || this.status?.busy === true;
  }

  get junction() {
    return this.status?.junction ?? null;
  }

  get tribe() {
    return this.status?.tribe ?? null;
  }

  get junctionUpToDate() {
    return (
      !!this.junction?.latest &&
      this.junction.installed === this.junction.latest.tag
    );
  }

  get canUpgradeJunction() {
    return (
      this.status?.ready &&
      this.junction?.available &&
      !!this.junction?.latest &&
      !this.junctionUpToDate &&
      !this.isBusy
    );
  }

  get canUpgradeTribe() {
    return this.status?.ready && this.tribe?.available && !this.isBusy;
  }

  get junctionPrevious() {
    const previous = this.junction?.previous;
    if (!previous) return null;
    return {
      date: this.formatDate(previous.created_at),
      label: previous.version ?? 'unknown version',
    };
  }

  get tribePrevious() {
    const previous = this.tribe?.previous;
    if (!previous) return null;
    return {
      date: this.formatDate(previous.created_at),
      label:
        (previous.version ?? []).find((p) => p.name === 'tribe/core')
          ?.version ?? 'unknown version',
    };
  }

  formatDate(seconds) {
    return new Date(seconds * 1000).toLocaleString();
  }

  @action
  setup(element) {
    element.addEventListener('show.bs.modal', () => {
      this.errorMessage = null;
      this.successMessage = null;
      this.log = '';
      this.loadStatus();
    });
  }

  @action
  async loadStatus() {
    this.isLoading = true;
    try {
      const response = await fetch(this.endpoint, {
        headers: { Accept: 'application/json' },
      });
      const data = await response.json();
      if (data.status === 'success') {
        this.status = data;
      } else {
        this.errorMessage = data.error_message ?? 'Could not load versions.';
      }
    } catch {
      this.errorMessage = 'Could not reach Tribe.';
    } finally {
      this.isLoading = false;
    }
  }

  async run(name, question) {
    if (!confirm(question)) return;

    this.runningAction = name;
    this.errorMessage = null;
    this.successMessage = null;
    this.log = '';

    try {
      const response = await fetch(this.endpoint, {
        method: 'POST',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ action: name }),
      });
      const data = await response.json();
      this.log = data.log ?? '';

      if (data.status === 'success') {
        this.status = data;
        this.successMessage = data.message;
        if (data.reload_junction) this.reloadJunction = true;
      } else {
        this.errorMessage = data.error_message ?? 'The request failed.';
        this.loadStatus();
      }
    } catch {
      this.errorMessage =
        'Lost contact with Tribe. Reopen this window to see the current state.';
    } finally {
      this.runningAction = null;
    }
  }

  @action
  upgradeJunction() {
    this.run(
      'upgrade_junction',
      `Update Junction to ${this.junction.latest.tag}? The current version is kept for one revert.`,
    );
  }

  @action
  upgradeTribe() {
    this.run(
      'upgrade_tribe',
      'Run composer update for Tribe? The current packages are kept for one revert.',
    );
  }

  @action
  revertJunction() {
    const previous = this.junctionPrevious;
    this.run(
      'revert_junction',
      `Revert Junction to ${previous.label} from ${previous.date}? The current version is not kept after the revert.`,
    );
  }

  @action
  revertTribe() {
    const previous = this.tribePrevious;
    this.run(
      'revert_tribe',
      `Revert Tribe packages to tribe/core ${previous.label} from ${previous.date}? The current packages are not kept after the revert.`,
    );
  }

  @action
  reload() {
    window.location.reload();
  }

  <template>
    <div
      class="modal fade"
      id="versionUpgradesModal"
      tabindex="-1"
      aria-labelledby="versionUpgradesModalLabel"
      aria-hidden="true"
      data-bs-backdrop="static"
      {{didInsert this.setup}}
    >
      <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="versionUpgradesModalLabel"><i
                class="fa-solid fa-circle-up"
              ></i>
              Version upgrades</h1>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
              disabled={{this.runningAction}}
            ></button>
          </div>

          <div class="modal-body">
            {{#if this.successMessage}}
              <div
                class="alert alert-success d-flex align-items-center justify-content-between"
              >
                <span><i class="fa-solid fa-circle-check"></i>
                  {{this.successMessage}}</span>
                {{#if this.reloadJunction}}
                  <button
                    type="button"
                    class="btn btn-sm btn-success"
                    {{on "click" this.reload}}
                  ><i class="fa-solid fa-rotate-right"></i>
                    Reload Junction</button>
                {{/if}}
              </div>
            {{/if}}

            {{#if this.errorMessage}}
              <div class="alert alert-danger">
                <i class="fa-solid fa-circle-xmark"></i>
                {{this.errorMessage}}
              </div>
            {{/if}}

            {{#if this.log}}
              <details class="mb-3">
                <summary class="small text-muted">Command output</summary>
                <pre
                  class="small bg-body-tertiary p-2 mt-2"
                  style="max-height:240px"
                >{{this.log}}</pre>
              </details>
            {{/if}}

            {{#if this.status}}
              {{#if (not this.status.ready)}}
                <div class="alert alert-warning">
                  The backups folder is not available to Tribe. Upgrades stay
                  disabled until
                  <code>applications/.versions</code>
                  is mounted at
                  <code>/var/www/versions</code>.
                </div>
              {{/if}}

              <div class="card mb-4">
                <div
                  class="card-header d-flex align-items-center justify-content-between"
                >
                  <span class="fw-bold"><i class="fa-solid fa-layer-group"></i>
                    Junction dist</span>
                  <button
                    type="button"
                    class="btn btn-sm btn-primary"
                    disabled={{not this.canUpgradeJunction}}
                    {{on "click" this.upgradeJunction}}
                  >
                    {{#if (eq this.runningAction "upgrade_junction")}}
                      <i class="fa-solid fa-spinner fa-spin"></i>
                      Updating
                    {{else}}
                      <i class="fa-solid fa-cloud-arrow-down"></i>
                      Update
                    {{/if}}
                  </button>
                </div>
                <div class="card-body small">
                  <div>Installed:
                    <span class="font-monospace">{{if
                        this.junction.installed
                        this.junction.installed
                        "unknown"
                      }}</span></div>
                  <div>Latest release:
                    {{#if this.junction.latest}}
                      <a
                        class="font-monospace"
                        href={{this.junction.latest.html_url}}
                        target="_blank"
                        rel="noopener noreferrer"
                      >{{this.junction.latest.tag}}</a>
                      {{#if this.junctionUpToDate}}
                        <span class="text-success">(up to date)</span>
                      {{/if}}
                    {{else}}
                      <span
                        class="text-danger"
                      >{{this.junction.latest_error}}</span>
                    {{/if}}
                  </div>
                  {{#if (not this.junction.available)}}
                    <div class="text-danger mt-2">Junction dist is not mounted
                      in the Tribe container.</div>
                  {{/if}}

                  {{#if this.junctionPrevious}}
                    <div
                      class="d-flex align-items-center justify-content-between mt-3 pt-2 border-top"
                    >
                      <span class="font-monospace text-muted">Previous:
                        {{this.junctionPrevious.label}}
                        ·
                        {{this.junctionPrevious.date}}</span>
                      <button
                        type="button"
                        class="btn btn-outline-warning btn-sm py-0 px-2"
                        disabled={{this.isBusy}}
                        {{on "click" this.revertJunction}}
                      ><i class="fa-solid fa-rotate-left"></i>
                        Revert</button>
                    </div>
                  {{/if}}
                </div>
              </div>

              <div class="card">
                <div
                  class="card-header d-flex align-items-center justify-content-between"
                >
                  <span class="fw-bold"><i class="fa-brands fa-php"></i>
                    Tribe composer packages</span>
                  <button
                    type="button"
                    class="btn btn-sm btn-primary"
                    disabled={{not this.canUpgradeTribe}}
                    {{on "click" this.upgradeTribe}}
                  >
                    {{#if (eq this.runningAction "upgrade_tribe")}}
                      <i class="fa-solid fa-spinner fa-spin"></i>
                      Updating
                    {{else}}
                      <i class="fa-solid fa-cloud-arrow-down"></i>
                      composer update
                    {{/if}}
                  </button>
                </div>
                <div class="card-body small">
                  {{#each this.tribe.packages as |pkg|}}
                    <div class="d-flex justify-content-between">
                      <span class="font-monospace">{{pkg.name}}</span>
                      <span class="font-monospace text-muted">{{if
                          pkg.version
                          pkg.version
                          "not installed"
                        }}</span>
                    </div>
                  {{/each}}
                  {{#if (not this.tribe.healthy)}}
                    <div class="text-danger mt-2">The installed packages do not
                      load. Revert to the previous version below.</div>
                  {{/if}}
                  {{#if (not this.tribe.available)}}
                    <div class="text-danger mt-2">Tribe's vendor folder is not
                      writable by php-fpm.</div>
                  {{/if}}

                  {{#if this.tribePrevious}}
                    <div
                      class="d-flex align-items-center justify-content-between mt-3 pt-2 border-top"
                    >
                      <span class="font-monospace text-muted">Previous:
                        tribe/core
                        {{this.tribePrevious.label}}
                        ·
                        {{this.tribePrevious.date}}</span>
                      <button
                        type="button"
                        class="btn btn-outline-warning btn-sm py-0 px-2"
                        disabled={{this.isBusy}}
                        {{on "click" this.revertTribe}}
                      ><i class="fa-solid fa-rotate-left"></i>
                        Revert</button>
                    </div>
                  {{/if}}
                </div>
              </div>
            {{else if this.isLoading}}
              <div class="text-center text-muted py-4"><i
                  class="fa-solid fa-spinner fa-spin"
                ></i>
                Checking versions</div>
            {{/if}}
          </div>

          <div class="modal-footer p-1 small text-muted justify-content-start">
            Uploads and the database are never changed. Only the version before
            the last update is kept, and a revert removes it.
          </div>
        </div>
      </div>
    </div>
  </template>
}
