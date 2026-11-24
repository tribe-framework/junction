import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { on } from '@ember/modifier';

export default class TypesCopyObjectModalComponent extends Component {
  @service store;
  @service types;
  @service type;
  @service object;

  @action
  async pushObject() {
    const vvv = this.object.currentObject.modules;
    delete vvv.id;
    delete vvv.slug;

    let obj = await this.store.createRecord(this.type.currentType.slug, {
      modules: { ...vvv },
    });

    await obj.save();

    this.type.loadTypeObjects(this.type.currentType);
    this.types.fetchAgain();
  }
  <template>
    {{#unless this.object.reloadingVars}}
      {{! Modal }}
      <div class="modal fade" id="copyObjectModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header">
              <h1 class="modal-title fs-5">Make a copy of this object?</h1>
              <button
                type="button"
                class="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              ></button>
            </div>
            <div class="modal-body fw-bold">
              {{this.object.currentObject.modules.title}}
            </div>
            <div class="modal-footer">
              <button
                type="button"
                class="btn btn-secondary"
                data-bs-dismiss="modal"
              >Close</button>
              <button
                type="button"
                class="btn btn-primary"
                data-bs-dismiss="modal"
                {{on "click" this.pushObject}}
              >Yes, make a copy</button>
            </div>
          </div>
        </div>
      </div>
    {{/unless}}
  </template>
}
