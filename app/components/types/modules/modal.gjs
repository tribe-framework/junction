import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import didInsert from '../../../modifiers/did-insert.js';
import { Input } from '@ember/component';
import notEq from 'ember-truth-helpers/helpers/not-eq';
import XToggle from '../../x-toggle.gjs';
import and from 'ember-truth-helpers/helpers/and';
import or from 'ember-truth-helpers/helpers/or';
import eq from 'ember-truth-helpers/helpers/eq';
import PowerSelect from 'ember-power-select/components/power-select';
import InputOptions from './input-options.gjs';
import { fn } from '@ember/helper';
import { on } from '@ember/modifier';

export default class TypesModulesModalComponent extends Component {
  @service type;
  @service types;
  @service module;
  @service colormodes;
  <template>
    {{! Modal }}
    <div
      class="modal fade"
      id="moduleModal"
      tabindex="-1"
      aria-labelledby="moduleModalLabel"
      aria-hidden="true"
      {{didInsert this.module.initModel}}
    >
      <div class="modal-dialog modal-dialog-scrollable modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h1
              class="modal-title fs-5"
              id="moduleModalLabel"
            >{{this.module.currentModule.input_slug}}</h1>
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
                <label class="fst-italic col-form-label fw-bold">slug</label>
              </div>
              <div class="my-1 col-12 col-md-7">
                <Input
                  disabled
                  @type="text"
                  @value={{this.module.currentModule.input_slug}}
                  class="form-control"
                />
              </div>
              <div class="my-1 col-12 col-md-3">
                <span class="form-text">Primary field. Usually
                  <em>title</em>
                  or
                  <em>name.</em></span>
              </div>
            </div>

            <div
              class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
            >
              <div class="my-1 py-0 col-12 col-md-2">
                <label
                  class="fst-italic col-form-label fw-bold"
                >placeholder</label>
              </div>
              <div class="my-1 col-12 col-md-7">
                <Input
                  @type="text"
                  @value={{mut this.module.currentModule.input_placeholder}}
                  class="form-control"
                />
              </div>
              <div class="my-1 col-12 col-md-3">
                <span class="form-text">Descriptor for the field.</span>
              </div>
            </div>

            {{#if (notEq this.module.currentModule.input_primary true)}}
              <div
                class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
              >
                <div class="my-1 py-0 col-12 col-md-2">
                  <label class="fst-italic col-form-label fw-bold">linked track</label>
                </div>
                <div class="my-1 col-12 col-md-7">
                  <XToggle
                    @theme="ios"
                    @variant={{this.colormodes.mode}}
                    @value={{this.module.restrictToLinkedOnly}}
                    @onToggle={{this.module.changeToRestrictToLinkedOnly}}
                  />
                </div>
                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">Dynamically links objects of another
                    track.</span>
                </div>
              </div>

              {{#if
                (and
                  (or
                    (eq this.module.selectedInputType.slug "select")
                    (eq this.module.selectedInputType.slug "number")
                  )
                  (eq this.module.restrictToLinkedOnly true)
                )
              }}
                <div
                  class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
                >
                  <div class="my-1 py-0 col-12 col-md-2">
                    <label class="fst-italic col-form-label fw-bold">choose
                      track</label>
                  </div>
                  <div class="my-1 col-12 col-md-7">
                    <PowerSelect
                      @selected={{this.module.linkedType}}
                      @options={{this.module.linkedTypesAvailable}}
                      @onChange={{this.module.changeLinkedType}}
                      @dropdownClass="in-modal-dropdown"
                      class="rounded-0 px-2 border-muted"
                      @placeholder="Select linked track"
                      as |tp|
                    >
                      {{tp}}
                    </PowerSelect>
                  </div>
                  <div class="my-1 col-12 col-md-3">
                    <span class="form-text">Choose the linked track</span>
                  </div>
                </div>
              {{/if}}

              <div
                class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
              >
                <div class="my-1 py-0 col-12 col-md-2">
                  <label class="fst-italic col-form-label fw-bold">type</label>
                </div>
                <div class="my-1 col-12 col-md-7">
                  {{#if (eq this.module.restrictToLinkedOnly true)}}
                    <PowerSelect
                      @selected={{this.module.selectedInputType}}
                      @options={{this.module.inputLinkedTypesOnly}}
                      @onChange={{this.module.changeInputType}}
                      @dropdownClass="in-modal-dropdown"
                      class="rounded-0 px-2 border-muted"
                      @placeholder="Select input type"
                      as |ip|
                    >
                      {{ip.title}}
                    </PowerSelect>
                  {{else}}
                    <PowerSelect
                      @selected={{this.module.selectedInputType}}
                      @options={{this.module.inputTypes}}
                      @onChange={{this.module.changeInputType}}
                      @dropdownClass="in-modal-dropdown"
                      class="rounded-0 px-2 border-muted"
                      @placeholder="Select input type"
                      as |ip|
                    >
                      {{ip.title}}
                    </PowerSelect>
                  {{/if}}
                </div>
                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">Form input type.</span>
                </div>
              </div>

              {{#if
                (and
                  (eq this.module.selectedInputType.slug "select")
                  (eq this.module.restrictToLinkedOnly false)
                )
              }}
                <InputOptions />
              {{/if}}

              {{#if
                (and
                  (notEq this.module.selectedInputType.slug "editorjs")
                  (notEq this.module.selectedInputType.slug "file_uploader")
                )
              }}
                <div
                  class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
                >
                  <div class="my-1 py-0 col-12 col-md-2">
                    <label
                      class="fst-italic col-form-label fw-bold"
                    >mandatory?</label>
                  </div>
                  <div class="my-1 col-12 col-md-7">
                    <XToggle
                      @theme="ios"
                      @variant={{this.colormodes.mode}}
                      @value={{this.module.inputRequired}}
                      @onToggle={{fn (mut this.module.inputRequired)}}
                    />
                  </div>
                  <div class="my-1 col-12 col-md-3">
                    <span class="form-text">Is it a required field?</span>
                  </div>
                </div>
              {{/if}}

              {{#if
                (or
                  (eq this.module.selectedInputType.slug "select")
                  (eq this.module.selectedInputType.slug "text")
                  (eq this.module.selectedInputType.slug "textarea")
                  (eq this.module.selectedInputType.slug "url")
                  (eq this.module.selectedInputType.slug "number")
                  (eq this.module.selectedInputType.slug "color")
                  (eq this.module.selectedInputType.slug "date")
                  (eq this.module.selectedInputType.slug "email")
                  (eq this.module.selectedInputType.slug "tel")
                  (eq this.module.selectedInputType.slug "datetime-local")
                )
              }}
                <div
                  class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
                >
                  <div class="my-1 py-0 col-12 col-md-2">
                    <label
                      class="fst-italic col-form-label fw-bold"
                    >multiple</label>
                  </div>
                  <div class="my-1 col-12 col-md-7">
                    <XToggle
                      @theme="ios"
                      @variant={{this.colormodes.mode}}
                      @value={{this.module.inputMultiple}}
                      @onToggle={{fn (mut this.module.inputMultiple)}}
                    />
                  </div>
                  <div class="my-1 col-12 col-md-3">
                    <span class="form-text">Allow multiple entries.</span>
                  </div>
                </div>
              {{/if}}

              <div
                class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
              >
                <div class="my-1 py-0 col-12 col-md-2">
                  <label class="fst-italic col-form-label fw-bold">list</label>
                </div>
                <div class="my-1 col-12 col-md-7">
                  <XToggle
                    @theme="ios"
                    @variant={{this.colormodes.mode}}
                    @value={{this.module.listField}}
                    @onToggle={{fn (mut this.module.listField)}}
                  />
                </div>
                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">List this field in the table view.</span>
                </div>
              </div>

              <div
                class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
              >
                <div class="my-1 py-0 col-12 col-md-2">
                  <label
                    class="fst-italic col-form-label fw-bold"
                  >searchable</label>
                </div>
                <div class="my-1 col-12 col-md-7">
                  <XToggle
                    @theme="ios"
                    @variant={{this.colormodes.mode}}
                    @value={{this.module.listSearchable}}
                    @onToggle={{fn (mut this.module.listSearchable)}}
                  />
                </div>
                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">Searchable field in table view.</span>
                </div>
              </div>

              <div
                class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
              >
                <div class="my-1 py-0 col-12 col-md-2">
                  <label
                    class="fst-italic col-form-label fw-bold"
                  >sort-able</label>
                </div>
                <div class="my-1 col-12 col-md-7">
                  <XToggle
                    @theme="ios"
                    @variant={{this.colormodes.mode}}
                    @value={{this.module.listSortable}}
                    @onToggle={{fn (mut this.module.listSortable)}}
                  />
                </div>
                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">Sort-able field in table view.</span>
                </div>
              </div>
            {{else}}
              <div
                class="row g-3 align-items-center my-3 border-bottom border-1 border-muted pb-3"
              >
                <div class="my-1 py-0 col-12 col-md-2">
                  <label
                    class="fst-italic col-form-label fw-bold"
                  >unique</label>
                </div>
                <div class="my-1 col-12 col-md-7">
                  <XToggle
                    @theme="ios"
                    @variant={{this.colormodes.mode}}
                    @value={{this.module.inputUnique}}
                    @onToggle={{fn (mut this.module.inputUnique)}}
                  />
                </div>
                <div class="my-1 col-12 col-md-3">
                  <span class="form-text">Never repeat primary field.</span>
                </div>
              </div>
            {{/if}}

          </div>
          <div
            class="modal-footer justify-content-between p-1 d-flex align-items-center"
          >
            {{#if (notEq this.module.currentModule.input_primary true)}}
              <button
                {{on "click" this.module.delete}}
                type="button"
                class="btn btn-danger"
              ><i class="fa-solid fa-trash"></i></button>
            {{else}}
              <div></div>
            {{/if}}
            <button
              {{on "click" this.module.save}}
              type="button"
              class="btn btn-primary"
            >Save changes</button>
          </div>
        </div>
      </div>
    </div>
  </template>
}
