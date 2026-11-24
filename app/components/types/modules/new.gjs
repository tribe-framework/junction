import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { Modal } from 'bootstrap';
import { later } from '@ember/runloop';
import didInsert from '../../../modifiers/did-insert.js';
import { Input } from '@ember/component';
import { on } from '@ember/modifier';

export default class TypesModulesNewComponent extends Component {
  @service type;
  @service module;
  @service colormodes;
  @tracked moduleName = '';
  @service types;
  @tracked modelBox = null;

  convertToSlug = (Text) => {
    return Text.toLowerCase()
      .replace(/ /g, '_')
      .replace(/[^\w-]+/g, '')
      .replace(/-/g, '_');
  };

  @action
  initModel() {
    this.modelBox = new Modal(document.getElementById('newModuleModel'), {});

    const myModalEl = document.getElementById('newModuleModel');
    myModalEl.addEventListener('hidden.bs.modal', async (event) => {
      this.types.fetchAgain();
    });
  }

  @action
  async save(e) {
    this.colormodes.buttonLoading(e);
    if (this.moduleName != '') {
      let slug = this.type.currentType.slug;
      var exists = false;

      this.types.json.modules[slug].modules.forEach((module) => {
        if (module.input_slug == this.convertToSlug(this.moduleName)) {
          exists = true;
        }
      });

      if (exists) {
        alert('A module with this name already exists.');
      } else {
        this.types.json.modules[slug].modules.push({
          input_slug: this.convertToSlug(this.moduleName),
          input_type: 'text',
          input_placeholder: this.moduleName,
          list_field: false,
          list_searchable: false,
          list_sortable: false,
          var_type: 'string',
        });
        await this.types.json.save();
        this.modelBox.hide();
        this.types.fetchAgain();
        document.querySelector('#track-' + slug).click();

        later(
          this,
          () => {
            document
              .querySelector('#' + slug + '-module-' + this.moduleName)
              .click();
            this.moduleName = '';
          },
          300,
        );
      }
      this.colormodes.buttonUnloading(e);

      moduleModal;
    } else {
      this.colormodes.buttonUnloading(e);
      alert('Module name field is compulsory.');
    }
  }
  <template>
    {{! Modal }}
    <div
      class="modal fade"
      id="newModuleModel"
      tabindex="-1"
      aria-labelledby="newModuleModelLabel"
      aria-hidden="true"
      {{didInsert this.initModel}}
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="newModuleModelLabel"><i
                class="fa-solid fa-plus"
              ></i>
              New Module</h1>
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
                <label class="fst-italic col-form-label fw-bold">field name</label>
              </div>
              <div class="my-1 col-12 col-md-7">
                <Input
                  @type="text"
                  @value={{this.moduleName}}
                  class="form-control"
                  placeholder="Eg. Body or publishing date or description"
                />
              </div>
              <div class="my-1 col-12 col-md-3">
                <span class="form-text">Please give a name to the input field</span>
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
