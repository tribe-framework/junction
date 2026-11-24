import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { Modal } from 'bootstrap';
import { later } from '@ember/runloop';
import didInsert from '../../modifiers/did-insert.js';
import { Input } from '@ember/component';
import XToggle from '../x-toggle.gjs';
import { fn, get } from '@ember/helper';
import { on } from '@ember/modifier';

export default class TypesEditModelComponent extends Component {
  @tracked trackName = '';
  @tracked trackPlural = '';
  @tracked trackURL = '';
  @tracked trackDescription = '';
  @tracked apiHooks = [];
  @tracked sendable = false;
  @tracked readonly = false;
  @tracked editable = true;
  @tracked trackPrimary = 'title';
  @service types;
  @service colormodes;
  @service type;
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
    this.modelBox = new Modal(document.getElementById('editModel'), {});

    const myModalEl = document.getElementById('editModel');
    myModalEl.addEventListener('hidden.bs.modal', async (event) => {
      this.types.fetchAgain();
    });
    myModalEl.addEventListener('show.bs.modal', async (event) => {
      let typeSlug = this.type.currentType.slug;
      this.trackName = this.types.json.modules[typeSlug]['name'];
      this.trackPlural = this.types.json.modules[typeSlug]['plural'];
      this.trackURL = this.types.json.modules[typeSlug]['url'];
      this.trackDescription = this.types.json.modules[typeSlug]['description'];
      this.apiHooks = this.types.json.modules[typeSlug]['api_hooks'];
      this.sendable = this.types.json.modules[typeSlug]['sendable'];
      this.readonly = this.types.json.modules[typeSlug]['readonly'];
      this.editable =
        this.types.json.modules[typeSlug]['editable'] !== undefined
          ? this.types.json.modules[typeSlug]['editable']
          : true;
    });
  }

  @action
  async save(e) {
    if (this.trackName != '' && this.trackPlural != '') {
      this.colormodes.buttonLoading(e);
      let typeSlug = this.type.currentType.slug;
      this.types.json.modules[typeSlug]['name'] = this.trackName;
      this.types.json.modules[typeSlug]['plural'] = this.trackPlural;
      this.types.json.modules[typeSlug]['url'] = this.trackURL;
      this.types.json.modules[typeSlug]['description'] = this.trackDescription;
      this.types.json.modules[typeSlug]['api_hooks'] = this.apiHooks;
      this.types.json.modules[typeSlug]['sendable'] = this.sendable;
      this.types.json.modules[typeSlug]['readonly'] = this.readonly;
      this.types.json.modules[typeSlug]['editable'] = this.editable;

      await this.types.json.save();
      await this.types.fetchAgain();
      this.colormodes.buttonUnloading(e);
      this.modelBox.hide();
    } else {
      alert('Name and plural are compulsory.');
    }
  }
  <template>
    {{! Modal }}
    <div
      class="modal fade"
      id="editModel"
      tabindex="-1"
      data-bs-backdrop="static"
      aria-labelledby="editModelLabel"
      aria-hidden="true"
      {{didInsert this.initModel}}
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="editModelLabel"><i
                class="fa-solid fa-edit"
              ></i>
              Edit Track</h1>
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
                <label class="fst-italic col-form-label fw-bold">URL</label>
              </div>

              <div class="my-1 col-12 col-md-7">
                <Input
                  @type="text"
                  @value={{this.trackURL}}
                  class="form-control"
                  placeholder="https://domain.tld/{{this.type.currentType.slug}}"
                />
              </div>

              <div class="my-1 col-12 col-md-3">
                <span class="form-text">Viewing URL to prepend (optional)</span>
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

            <div class="row g-3 align-items-center my-3 pb-3">
              <div class="my-1 py-0 col-12 col-md-2">
                <label
                  class="fst-italic col-form-label fw-bold"
                >editable?</label>
              </div>

              <div class="my-1 col-12 col-md-7">
                <XToggle
                  @theme="ios"
                  @variant={{this.colormodes.mode}}
                  @value={{this.editable}}
                  @onToggle={{fn (mut this.editable)}}
                />
              </div>

              <div class="my-1 col-12 col-md-3">
                <span class="form-text">Editing allowed after creation</span>
              </div>
            </div>

            <div class="row g-3 align-items-center my-3 pb-3">
              <div class="my-1 py-0 col-12 col-md-2">
                <label
                  class="fst-italic col-form-label fw-bold"
                >readonly?</label>
              </div>

              <div class="my-1 col-12 col-md-7">
                <XToggle
                  @theme="ios"
                  @variant={{this.colormodes.mode}}
                  @value={{this.readonly}}
                  @onToggle={{fn (mut this.readonly)}}
                />
              </div>

              <div class="my-1 col-12 col-md-3">
                <span class="form-text">New creation not allowed</span>
              </div>
            </div>

            <div class="row g-3 align-items-center my-3 pb-3">
              <div class="my-1 py-0 col-12 col-md-2">
                <label
                  class="fst-italic col-form-label fw-bold"
                >sendable?</label>
              </div>

              <div class="my-1 col-12 col-md-7">
                <XToggle
                  @theme="ios"
                  @variant={{this.colormodes.mode}}
                  @value={{this.sendable}}
                  @onToggle={{fn (mut this.sendable)}}
                />
              </div>

              <div class="my-1 col-12 col-md-3">
                <span class="form-text">Triggers the Hook URL on-send, and is
                  non-editable after sending.</span>
              </div>
            </div>

            {{#if this.sendable}}
              <div class="row g-3 align-items-start my-3 pb-3">
                <div class="my-1 py-0 col-12 col-md-2">
                  <label
                    class="fst-italic col-form-label fw-bold"
                  >on_create</label>
                </div>

                <div class="my-1 col-12 col-md-7">
                  <Input
                    @type="url"
                    @value={{mut (get this.apiHooks "on_create")}}
                    class="form-control"
                    placeholder="https://...."
                  />
                </div>

                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">Create Hook URL</span>
                </div>
              </div>

              <div class="row g-3 align-items-start my-3 pb-3">
                <div class="my-1 py-0 col-12 col-md-2">
                  <label
                    class="fst-italic col-form-label fw-bold"
                  >on_read</label>
                </div>

                <div class="my-1 col-12 col-md-7">
                  <Input
                    @type="url"
                    @value={{mut (get this.apiHooks "on_read")}}
                    class="form-control"
                    placeholder="https://...."
                  />
                </div>

                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">Read Hook URL</span>
                </div>
              </div>

              <div class="row g-3 align-items-start my-3 pb-3">
                <div class="my-1 py-0 col-12 col-md-2">
                  <label
                    class="fst-italic col-form-label fw-bold"
                  >on_update</label>
                </div>

                <div class="my-1 col-12 col-md-7">
                  <Input
                    @type="url"
                    @value={{mut (get this.apiHooks "on_update")}}
                    class="form-control"
                    placeholder="https://...."
                  />
                </div>

                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">Update Hook URL</span>
                </div>
              </div>

              <div class="row g-3 align-items-start my-3 pb-3">
                <div class="my-1 py-0 col-12 col-md-2">
                  <label
                    class="fst-italic col-form-label fw-bold"
                  >on_delete</label>
                </div>

                <div class="my-1 col-12 col-md-7">
                  <Input
                    @type="url"
                    @value={{mut (get this.apiHooks "on_delete")}}
                    class="form-control"
                    placeholder="https://...."
                  />
                </div>

                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">Delete Hook URL</span>
                </div>
              </div>
            {{/if}}
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
