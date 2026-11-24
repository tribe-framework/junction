import Component from '@glimmer/component';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later } from '@ember/runloop';
import ENV from 'junction/config/environment';
import JsonDisplay from './blueprint/json-display.gjs';
import tooltip from '../../modifiers/tooltip.js';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';

export default class TypesBlueprintObjectModalComponent extends Component {
  @service object;

  unixTimestampToLocalTime = (unixTimestamp) => {
    const date = new Date(unixTimestamp * 1000); // Convert seconds to milliseconds

    return date.toLocaleDateString('en-UK', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true,
    });
  };

  @action
  copyJSON(object, e) {
    e.target.innerHTML = 'Copied!';
    navigator.clipboard.writeText(JSON.stringify(object, null, '\t'));

    later(
      this,
      () => {
        e.target.innerHTML = '<i class="fa-solid fa-copy"></i> Copy JSON';
      },
      2000,
    );
  }

  @action
  copyAPILink(type, id, e) {
    e.target.innerHTML = 'Copied!';
    navigator.clipboard.writeText(
      ENV.TribeENV.API_URL + '/api.php/' + type + '/' + id,
    );

    later(
      this,
      () => {
        e.target.innerHTML = '<i class="fa-solid fa-copy"></i> Copy API URL';
      },
      2000,
    );
  }
  <template>
    {{! Modal }}
    <div
      class="modal fade"
      id="blueprintObjectModal"
      tabindex="-1"
      aria-labelledby="blueprintObjectModalLabel"
      aria-hidden="true"
    >
      <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="blueprintObjectModalLabel"><span
                class="text-primary"
              >{ object-blueprint }</span>
              {{this.object.currentType.name}}
              #{{this.object.currentObject.id}}</h1>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body"><JsonDisplay
              @jsondata={{this.object.currentObject.modules}}
            /></div>

          {{#if this.object.currentObject}}
            <div
              class="modal-footer d-flex align-items-center justify-content-between p-0"
            >
              <div
                class="d-flex align-items-center justify-content-start text-uppercase text-muted ps-2"
              ><div
                  {{tooltip}}
                  data-bs-html="true"
                  data-bs-toggle="tooltip"
                  data-bs-title="Last updated<br>
            {{this.unixTimestampToLocalTime
                    this.object.currentObject.modules.updated_on
                  }}<br><em>Created<br>
            {{this.unixTimestampToLocalTime
                    this.object.currentObject.modules.created_on
                  }}</em>"
                ><i class="fa-solid fa-circle-info"></i></div></div>
              <div class="d-flex align-items-center justify-content-end">
                <button
                  {{on
                    "click"
                    (fn this.copyJSON this.object.currentObject.modules)
                  }}
                  type="button"
                  class="btn btn-sm btn-secondary ms-2"
                ><i class="fa-solid fa-copy"></i> Copy JSON</button>
                <button
                  {{on
                    "click"
                    (fn
                      this.copyAPILink
                      this.object.currentType.slug
                      this.object.currentObject.id
                    )
                  }}
                  type="button"
                  class="btn btn-sm btn-primary ms-2"
                ><i class="fa-solid fa-copy"></i> Copy API URL</button>
              </div>
            </div>
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
