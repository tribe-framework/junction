import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { Modal } from 'bootstrap';
import ENV from 'junction/config/environment';
import didInsert from '../../modifiers/did-insert.js';
import { Input } from '@ember/component';
import { get } from '@ember/helper';
import Textarea from './editor/textarea.gjs';
import Checkbox from './editor/checkbox.gjs';
import { on } from '@ember/modifier';

export default class TypesWebappComponent extends Component {
  @service types;
  @service colormodes;
  @tracked webappBox = null;

  get isJunctionExpress() {
    if (ENV.JUNCTION_SLUG == 'junction') {
      return false;
    } else {
      return true;
    }
  }

  @action
  initWebapp() {
    this.webappBox = new Modal(document.getElementById('typesWebapp'), {});

    const myModalEl = document.getElementById('typesWebapp');
    myModalEl.addEventListener('hidden.bs.modal', async (event) => {
      this.types.fetchAgain();
    });
  }

  @action
  async save(e) {
    this.colormodes.buttonLoading(e);
    await this.types.json.save();
    this.colormodes.buttonUnloading(e);
    this.webappBox.hide();
  }
  <template>
    {{! Modal }}
    <div
      class="modal fade"
      id="typesWebapp"
      tabindex="-1"
      aria-labelledby="typesWebappLabel"
      aria-hidden="true"
      {{didInsert this.initWebapp}}
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="typesWebappLabel"><i
                class="fa-solid fa-gear"
              ></i>
              Settings</h1>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body">
            <div
              class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
            >
              <div class="my-1 py-0 col-12 col-md-2">
                <label class="fst-italic col-form-label fw-bold">name</label>
              </div>
              <div class="my-1 col-12 col-md-7">
                {{#if this.isJunctionExpress}}
                  <Input
                    disabled
                    @type="text"
                    @value={{mut
                      (get (get this.types.json.modules "webapp") "name")
                    }}
                    class="form-control"
                  />
                {{else}}
                  <Input
                    @type="text"
                    @value={{mut
                      (get (get this.types.json.modules "webapp") "name")
                    }}
                    class="form-control"
                  />
                {{/if}}
              </div>
              <div class="my-1 col-12 col-md-3">
                {{#if this.isJunctionExpress}}
                  <span class="form-text">A name for your Junction.</span>
                {{else}}
                  <span class="form-text">A name for your Junction.
                    <a
                      href="https://junction.express/junctions"
                      target="_blank"
                      rel="noopener noreferrer"
                    >Click here to edit.</a></span>
                {{/if}}
              </div>
            </div>

            <Textarea
              @typeKey="description"
              @typeSlug="webapp"
              @helpText="Short description."
            />
            <Checkbox
              @typeKey="soft_delete_records"
              @typeSlug="webapp"
              @helpText="To make sure your records never get fully deleted."
            />
            <Checkbox
              @typeKey="block_read_access_without_apikey"
              @typeSlug="webapp"
              @helpText="Block public access to all API calls."
            />
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
