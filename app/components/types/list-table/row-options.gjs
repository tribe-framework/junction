import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { Modal } from 'bootstrap';
import { later } from '@ember/runloop';
import eq from 'ember-truth-helpers/helpers/eq';
import { on } from '@ember/modifier';
import { fn, concat } from '@ember/helper';
import not from 'ember-truth-helpers/helpers/not';
import or from 'ember-truth-helpers/helpers/or';
import fileUrl from '../../../helpers/file-url';

export default class TypesListTableRowOptionsComponent extends Component {
  isLastSlashOrEquals = (id) => {
    let last = id.substr(id.length - 1);
    if (last == '/' || last == '=') return true;
    else return false;
  };

  @service object;
  @service type;
  @service colormodes;
  @service blueprints;

  @action
  openBlueprintModal() {
    this.object.activateCurrentObject(this.args.object);
    this.object.currentType = this.args.type;
    let bp = new Modal(document.getElementById('blueprintObjectModal'), {});
    bp.show();
  }

  @action
  openEditModal() {
    this.object.reloadingVars = true;
    this.object.activateCurrentObject(this.args.object);
    this.object.currentType = this.args.type;
    this.object.reloadingVars = false;
    let bp = new Modal(document.getElementById('editObjectModal'), {});
    bp.show();
  }

  @action
  openCopyModal() {
    this.object.reloadingVars = true;
    this.object.activateCurrentObject(this.args.object);
    this.object.currentType = this.args.type;
    this.object.reloadingVars = false;
    let bp = new Modal(document.getElementById('copyObjectModal'), {});
    bp.show();
  }

  @action
  async restoreRecord() {
    this.object.activateCurrentObject(this.args.object);
    this.object.currentObject.type = this.args.object.modules.deleted_type;
    this.object.currentObject.modules.type =
      this.args.object.modules.deleted_type;
    this.args.object.modules.deleted_type = '';
    await this.object.currentObject.save();
    this.type.search();
  }
  <template>
    <div
      class="d-none position-absolute bottom-0 end-0 bg-none"
      id="row-options-{{@object.id}}"
    >
      <div
        class="position-relative w-100 p-1 d-flex justify-content-lg-between align-items-center"
        style="z-index:1"
      >
        <div class="d-flex align-items-center">
          <span
            class="small mb-n1 me-1 bg-none border-0 font-weight-bold text-uppercase text-{{this.colormodes.inverseMode}}"
          >
            {{#if (eq @object.modules.content_privacy "public")}}
              <span class="text-success"><i
                  class="fa-solid fa-bullhorn"
                ></i></span>
            {{else if (eq @object.modules.content_privacy "private")}}
              <span class="text-danger"><i class="fa-solid fa-lock"></i></span>
            {{else if (eq @object.modules.content_privacy "sent")}}
              <span class="text-primary"><i
                  class="fa-solid fa-paper-plane"
                ></i></span>
            {{else if (eq @object.modules.content_privacy "pending")}}
              <span class="text-warning"><i
                  class="fa-solid fa-hourglass-half"
                ></i></span>
            {{else}}
              <span class="text-{{this.colormodes.inverseMode}}"><i
                  class="fa-solid fa-paragraph"
                ></i></span>
            {{/if}}
            <span
              class="d-none d-lg-inline"
            >{{@object.modules.content_privacy}}</span>
          </span>

          {{#if (eq @type.slug "deleted_record")}}
            <button
              class="badge badge-sm border bg-success border-1 border-{{this.colormodes.mode}}
                text-{{this.colormodes.mode}}
                font-weight-bold text-uppercase"
              {{on "click" this.restoreRecord}}
              type="button"
            ><i class="fa-solid fa-trash-arrow-up"></i><span
                class="d-none d-lg-inline"
              >&nbsp;Restore</span></button>
          {{/if}}

          <button
            class="badge badge-sm border bg-{{this.colormodes.inverseMode}}
              border-1 border-{{this.colormodes.mode}}
              text-{{this.colormodes.mode}}
              font-weight-bold text-uppercase"
            {{on "click" this.openBlueprintModal}}
            type="button"
          ><i class="fa-solid fa-code"></i><span
              class="d-none d-lg-inline"
            >&nbsp;API</span></button>

          {{#if (eq @type.slug "blueprint_record")}}
            {{#if @object.modules.url}}
              <button
                {{on
                  "click"
                  (fn
                    this.blueprints.downloadCurrentBlueprint @object.modules.url
                  )
                }}
                class="badge badge-sm border bg-{{this.colormodes.inverseMode}}
                  border-1 border-{{this.colormodes.mode}}
                  text-{{this.colormodes.mode}}
                  font-weight-bold text-uppercase"
                type="button"
              ><i class="fa-solid fa-download"></i><span
                  class="d-none d-lg-inline"
                >&nbsp;Download</span></button>
            {{else}}
              <button
                {{on
                  "click"
                  (fn
                    this.blueprints.downloadCurrentBlueprint
                    @object.modules.types_json
                  )
                }}
                class="badge badge-sm border bg-{{this.colormodes.inverseMode}}
                  border-1 border-{{this.colormodes.mode}}
                  text-{{this.colormodes.mode}}
                  font-weight-bold text-uppercase"
                type="button"
              ><i class="fa-solid fa-download"></i><span
                  class="d-none d-lg-inline"
                >&nbsp;Download</span></button>
            {{/if}}
          {{/if}}

          {{#unless @type.sendable}}
            {{#if
              (not (or (eq @module.input_unique true) (eq @type.readonly true)))
            }}
              <button
                class="badge badge-sm border border-1 border-{{this.colormodes.mode}}
                  bg-{{this.colormodes.inverseMode}}
                  text-{{this.colormodes.mode}}
                  font-weight-bold text-uppercase"
                {{on "click" this.openCopyModal}}
                type="button"
              ><i class="fa-solid fa-copy"></i><span
                  class="d-none d-lg-inline"
                >&nbsp;Copy</span></button>
            {{/if}}
          {{/unless}}

          {{#if (eq @type.slug "file_record")}}
            <a
              class="badge badge-sm border border-1 border-{{this.colormodes.mode}}
                bg-{{this.colormodes.inverseMode}}
                text-{{this.colormodes.mode}}
                font-weight-bold text-uppercase text-decoration-none"
              href="{{fileUrl @object.modules.url}}"
              target="new"
            ><i class="fa-solid fa-up-right-from-square"></i><span
                class="d-none d-lg-inline"
              >&nbsp;View</span></a>
          {{else if @type.url}}
            <a
              class="badge badge-sm border border-1 border-{{this.colormodes.mode}}
                bg-{{this.colormodes.inverseMode}}
                text-{{this.colormodes.mode}}
                font-weight-bold text-uppercase text-decoration-none"
              href="{{if
                (this.isLastSlashOrEquals @type.url)
                (concat @type.url @object.modules.slug)
                (concat @type.url '/' @object.modules.slug)
              }}"
              target="new"
            ><i class="fa-solid fa-up-right-from-square"></i><span
                class="d-none d-lg-inline"
              >&nbsp;View</span></a>
          {{/if}}

          {{#if (not (or @type.readonly (eq @type.editable false)))}}
            <button
              class="badge badge-sm border border-1 border-{{this.colormodes.mode}}
                bg-{{this.colormodes.inverseMode}}
                text-{{this.colormodes.mode}}
                font-weight-bold text-uppercase"
              {{on "click" this.openEditModal}}
              type="button"
            ><i class="fa-solid fa-pen-to-square"></i>&nbsp;Edit</button>
          {{/if}}

        </div>
      </div>
    </div>
  </template>
}
