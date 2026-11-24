import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { later } from '@ember/runloop';
import ENV from 'junction/config/environment';
import CodeReference from '../api/code-reference.gjs';
import { on } from '@ember/modifier';
import { fn, get } from '@ember/helper';

export default class TypesTrackApiModalComponent extends Component {
  @service type;
  @service colormodes;
  @service types;

  @action
  copyAPILink(e) {
    e.target.innerHTML = 'Copied!';
    navigator.clipboard.writeText(
      ENV.TribeENV.API_URL + '/api.php/' + this.type.currentType.slug,
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
      id="trackAPIModal"
      tabindex="-1"
      aria-labelledby="trackAPIModalLabel"
      aria-hidden="true"
    >
      <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="trackAPIModalLabel">{
              {{this.type.currentType.name}}
              } API</h1>
            <button
              type="button"
              class="btn-close"
              data-bs-dismiss="modal"
              aria-label="Close"
            ></button>
          </div>
          <div class="modal-body">
            <p>Our APIs are written strictly to JSON:API v1.1 standards. Copy
              the API URL below to use it in your applications. Visit
              <a href="https://jsonapi.org" target="new">jsonapi.org</a>
              to know how to write detailed queries.</p>

            <CodeReference @typeSlug={{this.type.currentType.slug}} />
          </div>
          <div
            class="modal-footer justify-content-between p-1 d-flex align-items-center"
          >
            <div class="d-flex align-items-center justify-content-start">
              <button
                type="button"
                class="btn btn-outline-secondary btn-sm me-2"
                data-bs-dismiss="modal"
              >Close</button>
              <button
                data-bs-dismiss="modal"
                {{on
                  "click"
                  (fn
                    this.type.changeType
                    (get this.types.json.modules "apikey_record")
                  )
                }}
                type="button"
                class="btn btn-sm btn-outline-primary"
              ><i class="fa-solid fa-plug"></i>&nbsp;Junction API</button>
            </div>
            <button
              {{on "click" this.copyAPILink}}
              type="button"
              class="btn btn-sm btn-secondary ms-2"
            ><i class="fa-solid fa-copy"></i> Copy Track API URL</button>
          </div>
        </div>
      </div>
    </div>
  </template>
}
