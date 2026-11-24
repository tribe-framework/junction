import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { Modal } from 'bootstrap';
import { later } from '@ember/runloop';
import didInsert from '../../modifiers/did-insert.js';
import { Input } from '@ember/component';
import { on } from '@ember/modifier';

export default class TypesNewModelComponent extends Component {
  @tracked trackName = '';
  @tracked trackPlural = '';
  @tracked trackDescription = '';
  @tracked trackPrimary = 'title';
  @service types;
  @service router;
  @service colormodes;
  @tracked modelBox = null;

  get initiatedType() {}

  convertToSlug = (Text) => {
    return Text.toLowerCase()
      .replace(/ /g, '_')
      .replace(/[^\w-]+/g, '')
      .replace(/-/g, '_');
  };

  @action
  initModel() {
    this.modelBox = new Modal(document.getElementById('newModel'), {});

    const myModalEl = document.getElementById('newModel');
    myModalEl.addEventListener('hidden.bs.modal', async (event) => {
      this.types.fetchAgain();
    });
  }

  @action
  async save(e) {
    if (
      this.trackName != '' &&
      this.trackPlural != '' &&
      this.trackPrimary != ''
    ) {
      this.colormodes.buttonLoading(e);
      let typeSlug = this.convertToSlug(this.trackName);

      var exists = false;
      Object.keys(this.types.json.modules).forEach((track) => {
        if (track != 'webapp') {
          if (
            track == typeSlug ||
            this.types.json.modules[track].name.toLowerCase() ==
              this.trackName.toLowerCase() ||
            this.types.json.modules[track].plural.toLowerCase() ==
              this.trackName.toLowerCase() ||
            this.types.json.modules[track].name.toLowerCase() ==
              this.trackPlural.toLowerCase() ||
            this.types.json.modules[track].plural.toLowerCase() ==
              this.trackPlural.toLowerCase()
          ) {
            exists = true;
          }
        }
      });

      if (exists) {
        this.colormodes.buttonUnloading(e);
        alert('A track with this name already exists.');
      } else {
        this.types.json.modules[typeSlug] = {
          name: this.trackName,
          slug: typeSlug,
          plural: this.trackPlural,
          description: this.trackDescription,
          modules: [
            {
              input_slug: this.convertToSlug(this.trackPrimary),
              input_primary: true,
              input_type: 'text',
              var_type: 'string',
              input_placeholder: 'Enter ' + this.trackPrimary,
              input_unique: false,
              list_field: true,
              list_searchable: true,
              list_sortable: true,
            },
          ],
        };
        await this.types.json.save();
        await this.types.fetchAgain();
        this.colormodes.buttonUnloading(e);
        this.modelBox.hide();
        this.router.transitionTo('type', typeSlug);
      }
    } else {
      alert('Name, plural and primary fields are compulsory.');
    }
  }
  <template>
    {{! Modal }}
    <div
      class="modal fade"
      id="newModel"
      tabindex="-1"
      aria-labelledby="newModelLabel"
      aria-hidden="true"
      {{didInsert this.initModel}}
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="newModelLabel"><i
                class="fa-solid fa-plus"
              ></i>
              New Track</h1>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body">
            <div class="row g-3 align-items-start my-3 pb-3">
              <div class="my-1 py-0 col-12 col-md-2">
                <label
                  class="fst-italic col-form-label fw-bold"
                >singular</label>
              </div>
              <div class="my-1 col-12 col-md-7">
                <Input
                  @type="text"
                  @value={{this.trackName}}
                  class="form-control"
                  placeholder="Eg. category"
                />
              </div>
              <div class="my-1 col-12 col-md-3">
                <span class="form-text">Please give a name in singular format</span>
              </div>
            </div>
            <div class="row g-3 align-items-start my-3 pb-3">
              <div class="my-1 py-0 col-12 col-md-2">
                <label class="fst-italic col-form-label fw-bold">plural</label>
              </div>
              <div class="my-1 col-12 col-md-7">
                <Input
                  @type="text"
                  @value={{this.trackPlural}}
                  class="form-control"
                  placeholder="Eg. categories"
                />
              </div>
              <div class="my-1 col-12 col-md-3">
                <span class="form-text">Please give a name in plural format</span>
              </div>
            </div>
            <div class="row g-3 align-items-start my-3 pb-3">
              <div class="my-1 py-0 col-12 col-md-2">
                <label class="fst-italic col-form-label fw-bold">primary</label>
              </div>
              <div class="my-1 col-12 col-md-7">
                <Input
                  @type="text"
                  @value={{this.trackPrimary}}
                  class="form-control"
                  placeholder="Eg. title"
                />
              </div>
              <div class="my-1 col-12 col-md-3">
                <span class="form-text">Name of the primary field</span>
              </div>
            </div>
            <div class="row g-3 align-items-start my-3 pb-3">
              <div class="my-1 py-0 col-12 col-md-2">
                <label
                  class="fst-italic col-form-label fw-bold"
                >description</label>
              </div>
              <div class="my-1 col-12 col-md-7">
                <Input
                  @type="text"
                  @value={{this.trackDescription}}
                  class="form-control"
                  placeholder="(optional description)"
                />
              </div>
              <div class="my-1 col-12 col-md-3">
                <span class="form-text">A short description (optional)</span>
              </div>
            </div>
          </div>
          <div
            class="modal-footer p-1 d-flex align-items-center justify-content-between"
          >
            <button
              type="button"
              class="btn btn-outline-secondary"
              data-bs-dismiss="modal"
            >Close without saving</button>
            <button
              type="button"
              {{on "click" this.save}}
              class="btn btn-primary"
            >Save changes</button>
          </div>
        </div>
      </div>
    </div>
  </template>
}
