import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { Modal } from 'bootstrap';
import { get, fn } from '@ember/helper';
import { on } from '@ember/modifier';
import RowOptions from '../../hooks/row-options.gjs';
import RowOptions0 from './row-options.gjs';

export default class TypesListTableRowComponent extends Component {
  @service colormodes;
  @service object;
  @service store;

  @tracked isShowing = false;
  @tracked isSelected = false;

  @action
  async showBlueprintObjectModal(tp, id) {
    let o = await this.store.findRecord(tp, id);
    this.object.activateCurrentObject(o);
    this.object.currentType = tp;
    let bp = new Modal(document.getElementById('blueprintObjectModal'), {});
    bp.show();
  }

  isArray(value) {
    return Array.isArray(value);
  }

  isCSV(value) {
    if (typeof value !== 'string') return false;
    // Check if it's a string with comma-separated values
    return (
      value.includes(',') && value.split(',').some((item) => item.trim() !== '')
    );
  }

  split(string, separator) {
    if (typeof string !== 'string') return [];
    return string.split(separator);
  }

  trim(string) {
    if (typeof string !== 'string') return string;
    return string.trim();
  }

  inArray = (needle, haysack) => {
    const index = haysack.indexOf(needle);
    if (index > -1) {
      this.isSelected = true;
      return true;
    } else {
      this.isSelected = false;
      return false;
    }
  };

  @action
  showOptions() {
    document
      .querySelector('#row-options-' + this.args.object.id)
      .classList.remove('d-none');
    document
      .querySelector('#row-options-' + this.args.object.id)
      .classList.add('d-block');
  }

  @action
  hideOptions() {
    document
      .querySelector('#row-options-' + this.args.object.id)
      .classList.add('d-none');
    document
      .querySelector('#row-options-' + this.args.object.id)
      .classList.remove('d-block');
  }

  @action
  toggleSelection() {
    if (this.isSelected === false) {
      document
        .querySelector('#row-' + this.args.object.id)
        .classList.add('bg-info');
      this.isSelected = true;
      this.args.addToSelectedRowIDs(this.args.type.slug, this.args.object.id);
    } else {
      document
        .querySelector('#row-' + this.args.object.id)
        .classList.remove('bg-info');
      this.isSelected = false;
      this.args.removeFromSelectedRowIDs(
        this.args.type.slug,
        this.args.object.id,
      );
    }
  }

  @action
  toggleOptions() {
    if (this.isShowing === false) {
      document
        .querySelector('#row-options-' + this.args.object.id)
        .classList.remove('d-none');
      document
        .querySelector('#row-options-' + this.args.object.id)
        .classList.add('d-block');
      this.isShowing = true;
    } else {
      document
        .querySelector('#row-options-' + this.args.object.id)
        .classList.add('d-none');
      document
        .querySelector('#row-options-' + this.args.object.id)
        .classList.remove('d-block');
      this.isShowing = false;
    }
  }
  <template>
    <tr
      id="row-{{@object.id}}"
      class="border-dark
        {{if
          (this.inArray @object.id (get @selectedRowIDs @type.slug))
          'bg-secondary'
        }}"
    >
      <th
        class="border-end border-start border-1 border-dark"
        scope="row"
        {{on "click" this.toggleSelection}}
      >
        {{#if this.isSelected}}
          <i
            class="fa-solid fa-circle-check"
          ></i>
        {{else}}
          <i
            class="fa-solid fa-circle"
          ></i>
        {{/if}}
        {{@object.id}}
      </th>

      {{#each @type.modules as |module|}}
        {{#if module.list_field}}
          {{#if module.input_primary}}
            <td
              class="position-relative border-end border-1 border-dark"
              {{on "mouseover" this.showOptions}}
              {{on "mouseout" this.hideOptions}}
            >
              <div
                class="text-ellipsis"
                {{on "touchend" this.toggleOptions}}
              >{{get @object.modules module.input_slug}}</div>

              <RowOptions
                @object={{@object}}
                @type={{@type}}
                @module={{module}}
              />

              <RowOptions0
                @object={{@object}}
                @type={{@type}}
                @module={{module}}
              />
            </td>
          {{else}}
            <td
              class="position-relative border-end border-1 border-dark"
              {{on "mouseover" this.showOptions}}
              {{on "mouseout" this.hideOptions}}
            >
              <div class="text-ellipsis" {{on "touchend" this.toggleOptions}}>
                {{#if module.linked_type}}
                  {{#if (this.isArray (get @object.modules module.input_slug))}}
                    <div class="d-flex flex-wrap gap-1">
                      {{#each
                        (get @object.modules module.input_slug)
                        as |item|
                      }}
                        <div
                          class="badge bg-{{this.colormodes.inverseMode}}
                            text-{{this.colormodes.mode}}
                            text-ellipsis cursor-pointer"
                          title="Click to view the linked object"
                          {{on
                            "click"
                            (fn
                              this.showBlueprintObjectModal
                              module.linked_type
                              item
                            )
                          }}
                        >
                          {{item}}
                        </div>
                      {{/each}}
                    </div>
                  {{else if
                    (this.isCSV (get @object.modules module.input_slug))
                  }}
                    <div class="d-flex flex-wrap gap-1">
                      {{#each
                        (this.split (get @object.modules module.input_slug) ",")
                        as |item|
                      }}
                        <div
                          class="badge bg-{{this.colormodes.inverseMode}}
                            text-{{this.colormodes.mode}}
                            text-ellipsis cursor-pointer"
                          title="Click to view the linked object"
                          {{on
                            "click"
                            (fn
                              this.showBlueprintObjectModal
                              module.linked_type
                              (this.trim item)
                            )
                          }}
                        >
                          {{this.trim item}}
                        </div>
                      {{/each}}
                    </div>
                  {{else if (get @object.modules module.input_slug)}}
                    <div
                      title="Click to view the linked object"
                      class="badge bg-{{this.colormodes.inverseMode}}
                        text-{{this.colormodes.mode}}
                        text-ellipsis cursor-pointer"
                      {{on
                        "click"
                        (fn
                          this.showBlueprintObjectModal
                          module.linked_type
                          (get @object.modules module.input_slug)
                        )
                      }}
                    >
                      {{get @object.modules module.input_slug}}
                    </div>
                  {{/if}}
                {{else}}
                  {{get @object.modules module.input_slug}}
                {{/if}}
              </div>
            </td>
          {{/if}}
        {{/if}}
      {{/each}}
    </tr>
  </template>
}
