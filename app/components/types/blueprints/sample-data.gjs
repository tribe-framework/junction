import Component from '@glimmer/component';
import { service } from '@ember/service';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';

export default class TypesBlueprintsSampleDataComponent extends Component {
  @service blueprints;
  @service colormodes;
  @service type;
  <template>
    {{! Modal }}
    <div
      class="modal fade"
      id="sampleDataPromptModal"
      tabindex="-1"
      aria-labelledby="sampleDataPromptModalLabel"
      aria-hidden="true"
    >
      <div class="modal-dialog modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header">
            <h1
              class="modal-title fst-italic fs-5"
              id="sampleDataPromptModalLabel"
            >Sample Data for
              <span
                class="text-capitalize"
              >{{this.type.currentType.plural}}</span></h1>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body">
            Are you sure you wish to generate sample data? Executing this will
            add 3 to 10 sample objects to this track.
          </div>
          <div
            class="modal-footer d-flex align-items-center justify-content-end p-0"
          >
            <div class="d-flex align-items-center justify-content-end">
              <button
                {{on "click" this.blueprints.getSampleData}}
                type="button"
                class="btn btn-primary ms-2"
              >Generate sample data &rarr;</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </template>
}
