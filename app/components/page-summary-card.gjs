import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { later } from '@ember/runloop';
import Sortable from 'sortablejs';
import onClickOutside from 'ember-click-outside/modifiers/on-click-outside';
import lte from 'ember-truth-helpers/helpers/lte';
import and from 'ember-truth-helpers/helpers/and';
import notEq from 'ember-truth-helpers/helpers/not-eq';
import eq from 'ember-truth-helpers/helpers/eq';
import { concat, fn } from '@ember/helper';
import { on } from '@ember/modifier';
import gt from 'ember-truth-helpers/helpers/gt';

export default class PageSummaryCardComponent extends Component {
  @service types;
  @service type;
  @service router;
  @service store;
  @service colormodes;
  @service blueprints;
  @tracked sortable = null;
  @tracked activateReordering = false;
  @tracked modules = Object.entries(this.types.json.modules);
  @tracked reloadTypes = false;

  get typesCount() {
    return this.modules.length;
  }

  @action
  changeType(type) {
    this.type.clearSearchQuery();
    this.type.editorJSOnTypeChange();
    this.type.currentType = type;
    this.type.loadTypeObjects();
    this.router.transitionTo('type', type);
  }

  @action
  startWobble() {
    this.activateReordering = true;
    this.initDragDrop();
  }

  @action
  stopWobble() {
    this.activateReordering = false;
    this.stopDragDrop();
  }

  @action
  stopDragDrop() {
    this.sortable = null;
  }

  @action
  initDragDrop() {
    this.sortable = new Sortable(document.querySelector('#track-names'), {
      group: 'track-names', // or { name: "...", pull: [true, false, 'clone', array], put: [true, false, array] }
      sort: true, // sorting inside list
      delay: 0, // time in milliseconds to define when the sorting should start
      delayOnTouchOnly: false, // only delay if user is using touch
      touchStartThreshold: 0, // px, how many pixels the point should move before cancelling a delayed drag event
      disabled: false, // Disables the sortable if set to true.
      store: null, // @see Store
      animation: 150, // ms, animation speed moving items when sorting, `0` — without animation
      easing: 'cubic-bezier(1, 0, 0, 1)', // Easing for animation. Defaults to null. See https://easings.net/ for examples.
      handle: '.track-name-btn', // Drag handle selector within list items
      filter: '.ignore-elements', // Selectors that do not lead to dragging (String or Function)
      preventOnFilter: true, // Call `event.preventDefault()` when triggered `filter`
      draggable: '.track-name-btn', // Specifies which items inside the element should be draggable

      dataIdAttr: 'data-type-slug', // HTML attribute that is used by the `toArray()` method

      ghostClass: 'sortable-ghost', // Class name for the drop placeholder
      chosenClass: 'sortable-chosen', // Class name for the chosen item
      dragClass: 'sortable-drag', // Class name for the dragging item

      swapThreshold: 1, // Threshold of the swap zone
      invertSwap: false, // Will always use inverted swap zone if set to true
      invertedSwapThreshold: 1, // Threshold of the inverted swap zone (will be set to swapThreshold value by default)
      direction: 'horizontal', // Direction of Sortable (will be detected automatically if not given)

      forceFallback: false, // ignore the HTML5 DnD behaviour and force the fallback to kick in

      fallbackClass: 'sortable-fallback', // Class name for the cloned DOM Element when using forceFallback
      fallbackOnBody: false, // Appends the cloned DOM Element into the Document's Body
      fallbackTolerance: 0, // Specify in pixels how far the mouse should move before it's considered as a drag.

      dragoverBubble: false,
      removeCloneOnHide: true, // Remove the clone element when it is not showing, rather than just hiding it
      emptyInsertThreshold: 5, // px, distance mouse must be from empty sortable to insert drag element into it

      // Element dragging ended
      onEnd: async (evt) => {
        this.modules = Object.entries(this.types.json.modules);
        this.modules = await array_move(
          this.modules,
          evt.oldIndex + 1,
          evt.newIndex + 1,
        );

        function array_move(arr, old_index, new_index) {
          if (new_index >= arr.length) {
            var k = new_index - arr.length + 1;
            while (k--) {
              arr.push(undefined);
            }
          }
          arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
          return arr; // for testing
        }
      },
    });

    this.initialOrder = this.sortable.toArray();
  }

  @action
  async ignoreReordering() {
    if (this.activateReordering === true) {
      this.type.loadingSearchResults = true;
      this.stopWobble();
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
  }

  @action
  async saveReordering() {
    this.type.loadingSearchResults = true;
    this.types.json.modules = await Object.fromEntries(this.modules);

    await this.types.json.save();
    later(
      this,
      async () => {
        window.location.reload(true);
      },
      500,
    );
  }
  <template>
    <div
      {{onClickOutside this.ignoreReordering}}
      class="card p-0 mt-5 border-0"
    >
      <h1
        class="display-6 mb-4 fw-normal text-muted
          {{if (lte this.typesCount 6) 'text-center' 'text-center'}}"
      >{{this.types.json.modules.webapp.name}}</h1>

      {{#unless this.reloadTypes}}
        <div
          id="track-names"
          class="card-body d-flex align-items-center justify-content-center flex-wrap p-0 col-lg-10 mx-auto"
        >
          {{#if this.types.json.modules.webapp.interfaces}}{{else}}
          {{/if}}
          {{#each-in this.types.json.modules as |key type|}}
            {{#if
              (and
                (and type.slug (notEq type.slug "webapp"))
                (notEq type.hidden true)
              )
            }}
              <div
                class="btn-group
                  {{if this.activateReordering 'wobble'}}
                  m-2 track-name-btn"
                data-type-slug={{type.slug}}
                role="group"
              ><button
                  title="{{if
                    this.activateReordering
                    'Hold and drag to reorder'
                    'Click to switch to this track'
                  }}"
                  id="track-{{type.slug}}"
                  {{on "click" (fn this.changeType type)}}
                  type="button"
                  class="text-capitalize fw-normal btn btn-{{if
                      (eq type.slug this.type.currentType.slug)
                      'primary'
                      (concat 'outline-' this.colormodes.inverseMode)
                    }}"
                >{{type.plural}}
                  <span
                    class="badge text-bg-light fw-light rounded-2 small"
                  >{{type.total_objects}}</span></button></div>
            {{/if}}
          {{/each-in}}

          {{#if (gt this.typesCount 6)}}
            {{#if this.types.json.modules.webapp.implementation_summary}}
              <div class="ignore-elements btn-group m-2" role="group"><button
                  type="button"
                  id="blueprintConsultationModal-btn"
                  data-bs-toggle="modal"
                  data-bs-target="#blueprintConsultationModal"
                  class="text-capitalize fw-normal btn btn-outline-{{this.colormodes.inverseMode}}"
                ><i class="fa-solid fa-circle-info"></i></button></div>
            {{/if}}
            <div class="ignore-elements btn-group m-2" role="group"><button
                id="track-new"
                type="button"
                data-bs-toggle="modal"
                data-bs-target="#newModel"
                class="text-capitalize fw-normal btn btn-outline-{{this.colormodes.inverseMode}}"
              ><i class="fa-solid fa-plus"></i></button></div>
          {{else}}
            <div
              class="d-flex flex-column align-items-center justify-content-center text-center"
            >
              <div class="ignore-elements my-3 mx-auto text-center">
                {{#if this.blueprints.myBlueprints}}
                  <button
                    type="button"
                    class="btn-lg fw-light fs-5 btn btn-outline-primary dropdown-toggle"
                    data-bs-toggle="dropdown"
                    aria-expanded="false"
                  >
                    <i class="fa-solid fa-circle-nodes"></i>
                    Use a blueprint
                    <i class="fa-solid fa-caret-down"></i>
                  </button>
                  <ul
                    class="dropdown-menu dropdown-menu-md-end overflow-y-scroll"
                    style="max-height:360px"
                  >
                    <li><h6 class="dropdown-header text-capitalize">Your
                        blueprints</h6></li>
                    {{#each this.blueprints.myBlueprints as |blueprint|}}
                      <li><a
                          {{on
                            "click"
                            (fn this.blueprints.changeBlueprint blueprint)
                          }}
                          href="#"
                          class="dropdown-item fs-5 fw-light"
                        >{{blueprint.modules.title}}</a></li>
                    {{/each}}

                    <li><hr class="dropdown-divider" /></li>
                    <li><h6 class="dropdown-header text-capitalize">Start Again</h6></li>
                    <li><a
                        {{on "click" this.blueprints.clearBlueprint}}
                        class="dropdown-item"
                        href="#"
                      >Clear the canvas</a></li>
                  </ul>
                {{/if}}

                <div class="fs-5 mt-4 fw-light mx-auto col-lg-7">Start by adding
                  a
                  <a
                    class="text-{{this.colormodes.inverseMode}}"
                    href="#newModel"
                    data-bs-toggle="modal"
                  >new track manually</a>
                  or select one of your saved blueprints above.</div>
              </div>
            </div>
          {{/if}}

          {{#if (gt this.typesCount 6)}}
            {{#if this.activateReordering}}
              <button
                id="track-new"
                type="button"
                {{on "click" this.ignoreReordering}}
                class="text-capitalize fw-normal border-0 btn me-n5"
              ><i class="fa-solid fa-lock-open"></i></button>
            {{else}}
              <button
                id="track-new"
                type="button"
                {{on "click" this.startWobble}}
                class="text-capitalize fw-normal border-0 btn me-n5"
              ><i class="fa-solid fa-lock"></i></button>
            {{/if}}
          {{/if}}
        </div>
      {{/unless}}

      {{#if this.activateReordering}}
        <div
          class="w-100 bg-{{this.colormodes.inverseMode}}
            p-1 d-flex align-items-center justify-content-between"
        >
          <button
            class="btn btn-outline-{{this.colormodes.mode}}"
            type="button"
            {{on "click" this.ignoreReordering}}
          ><i class="fa-solid fa-circle-xmark"></i> Do not save</button>
          <button
            class="btn btn-primary"
            type="button"
            {{on "click" this.saveReordering}}
          ><i class="fa-solid fa-circle-check"></i> Save reordering</button>
        </div>
      {{/if}}
    </div>
  </template>
}
