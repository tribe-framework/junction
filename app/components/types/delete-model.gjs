import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { Modal } from 'bootstrap';
import { later } from '@ember/runloop';
import didInsert from '../../modifiers/did-insert.js';
import { on } from '@ember/modifier';

export default class TypesDeleteModelComponent extends Component {
  @service type;
  @service types;
  @service router;
  @tracked modelBox = null;

  @action
  initModel() {
    this.modelBox = new Modal(document.getElementById('deleteModel'), {});

    const myModalEl = document.getElementById('deleteModel');
    myModalEl.addEventListener('hidden.bs.modal', async (event) => {
      this.types.fetchAgain();
    });
  }
  @action
  async delete() {
    if (this.type.currentType.slug !== undefined) {
      delete this.types.json.modules[this.type.currentType.slug];
      await this.types.json.save();

      this.modelBox.hide();
      later(
        this,
        () => {
          this.router.transitionTo('index');
        },
        700,
      );
    }
  }
  <template>
    {{! Modal }}
    <div
      class="modal fade"
      id="deleteModel"
      tabindex="-1"
      aria-labelledby="deleteModelLabel"
      aria-hidden="true"
      {{didInsert this.initModel}}
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="deleteModelLabel"><i
                class="fa-solid fa-triangle-exclamation"
              ></i>
              Remove Track:
              <strong>{{this.type.currentType.slug}}</strong></h1>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body">
            <h4>Are you sure you wish to disable this track? The objects in the
              track do NOT get deleted.</h4>
            <h4 class="text-danger">{{this.type.currentType.slug}}</h4>
          </div>
          <div
            class="modal-footer p-1 d-flex align-items-center justify-content-between"
          >
            <button
              type="button"
              {{on "click" this.delete}}
              class="btn btn-danger"
            >Confirm remove track</button>
            <button
              type="button"
              class="btn btn-outline-secondary"
              data-bs-dismiss="modal"
            >Close</button>
          </div>
        </div>
      </div>
    </div>
  </template>
}
