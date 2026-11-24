import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { later } from '@ember/runloop';
import and from 'ember-truth-helpers/helpers/and';
import notEq from 'ember-truth-helpers/helpers/not-eq';
import eq from 'ember-truth-helpers/helpers/eq';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';

export default class TypesModulesListComponent extends Component {
  @service type;
  @service colormodes;
  @service module;
  @service store;
  @service types;
  @tracked reloadTypes = false;

  @action
  highlightLinkages(l) {
    if (l !== undefined && document.querySelector('#track-' + l) !== null) {
      document.querySelector('#track-' + l).classList.add('bg-primary');
    }
  }

  @action
  unhighlightLinkages(l) {
    if (l !== undefined && document.querySelector('#track-' + l) !== null) {
      document.querySelector('#track-' + l).classList.remove('bg-primary');
    }
  }

  @action
  async ignoreReordering() {
    this.type.loadingSearchResults = true;
    this.args.stopWobble();
    this.reloadTypes = true;

    later(
      this,
      () => {
        this.reloadTypes = false;
      },
      1,
    );

    later(
      this,
      () => {
        this.type.loadingSearchResults = false;
      },
      500,
    );
  }

  @action
  async saveReordering() {
    this.type.loadingSearchResults = true;
    await this.types.json.save();
    await this.types.fetchAgain();
    this.type.loadingSearchResults = false;
    this.args.stopWobble();
  }
  <template>
    {{#unless this.reloadTypes}}

      {{#if this.type.currentType}}
        {{#if
          (and
            (notEq this.type.currentType.slug "deleted_record")
            (notEq this.type.currentType.slug "file_record")
          )
        }}
          <div
            id="module-names"
            class="d-flex align-items-center flex-wrap justify-content-center mb-5 col-lg-7 col-md-10 mx-auto"
          >
            {{#each this.type.currentType.modules as |module|}}
              {{#if (eq module.input_slug "content_privacy")}}
                <div
                  class="btn-group
                    {{if @activateReordering 'wobble'}}
                    mx-1 my-1 module-name-btn"
                  data-module-slug={{module.input_slug}}
                  role="group"
                ><button
                    disabled
                    title="{{if
                      @activateReordering
                      'Hold and drag to reorder'
                      'Click to edit module'
                    }}"
                    class="rounded-pill btn btn-outline-{{this.colormodes.inverseMode}}
                      px-3"
                    id="{{this.type.currentType.slug}}-module-{{module.input_slug}}"
                    type="button"
                  >{{module.input_slug}}</button></div>
              {{else}}
                <div
                  class="btn-group
                    {{if @activateReordering 'wobble'}}
                    mx-1 my-1 module-name-btn"
                  data-module-slug={{module.input_slug}}
                  role="group"
                ><button
                    title="{{if
                      @activateReordering
                      'Hold and drag to reorder'
                      'Click to edit module'
                    }}"
                    {{on "click" (fn this.module.changeModule module)}}
                    data-bs-target="#moduleModal"
                    data-bs-toggle="modal"
                    class="rounded-pill btn btn-outline-{{this.colormodes.inverseMode}}
                      px-3"
                    id="{{this.type.currentType.slug}}-module-{{module.input_slug}}"
                    type="button"
                    {{on
                      "mouseover"
                      (fn this.highlightLinkages module.linked_type)
                    }}
                    {{on
                      "mouseout"
                      (fn this.unhighlightLinkages module.linked_type)
                    }}
                  >{{if
                      module.linked_type
                      (htmlSafe '<i class="fa-solid fa-link"></i>')
                    }}
                    {{module.input_slug}}</button></div>
              {{/if}}
            {{/each}}
            <button
              data-bs-target="#newModuleModel"
              data-bs-toggle="modal"
              class="rounded-pill mx-1 btn btn-outline-{{this.colormodes.inverseMode}}
                my-1"
              type="button"
            ><i class="fa-solid fa-plus"></i></button>
          </div>
        {{else}}
          <div
            class="d-flex align-items-center justify-content-center mb-4"
          ></div>
        {{/if}}
      {{/if}}

      {{#if @activateReordering}}
        <div
          class="w-50 mt-n4 mb-5 mx-auto rounded-pill bg-{{this.colormodes.inverseMode}}
            p-1 d-flex align-items-center justify-content-between"
        >
          <button
            class="btn btn-sm btn-outline-{{this.colormodes.mode}} rounded-pill"
            type="button"
            {{on "click" this.ignoreReordering}}
          ><i class="fa-solid fa-circle-xmark"></i> Do not save</button>
          <button
            class="btn btn-sm btn-primary rounded-pill"
            type="button"
            {{on "click" this.saveReordering}}
          ><i class="fa-solid fa-circle-check"></i> Save reordering</button>
        </div>
      {{/if}}

    {{/unless}}
  </template>
}
