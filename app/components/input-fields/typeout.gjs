import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { later } from '@ember/runloop';
import { Textarea } from '@ember/component';
import { get, concat } from '@ember/helper';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';
import { on } from '@ember/modifier';

export default class InputFieldsTypeoutComponent extends Component {
  @tracked t = null;
  @tracked disabled = true;

  @action
  initTypeout() {
    this.disabled = false;
    this.t = null;

    later(
      this,
      () => {
        this.t = tinymce.init({
          selector:
            'textarea#' +
            this.args.type.slug +
            '-' +
            this.args.module.input_slug +
            '-' +
            this.args.id,
          plugins: 'advlist link image lists',
          license_key: 'gpl',
        });
        this.t = this.t;
      },
      300,
    );
  }

  @action
  saveTypeout() {
    this.args.mutObjectModuleValue(
      this.args.module.input_slug,
      tinymce
        .get(
          this.args.type.slug +
            '-' +
            this.args.module.input_slug +
            '-' +
            this.args.id,
        )
        .getContent(),
    );

    later(
      this,
      () => {
        this.disabled = true;
      },
      300,
    );
  }
  <template>
    <div class="mb-3">
      {{#if this.disabled}}
        <Textarea
          disabled="disabled"
          @value={{get @object @module.input_slug}}
          class="form-control"
          placeholder={{@module.input_placeholder}}
        />
      {{else}}
        <Textarea
          id={{concat @type.slug "-" @module.input_slug "-" @id}}
          @value={{get @object @module.input_slug}}
          class="form-control"
          placeholder={{@module.input_placeholder}}
          autocomplete="off"
        />
      {{/if}}

      <div
        class="form-text text-end d-flex align-items-center justify-content-end"
      >
        <span class="me-2">{{if
            @module.input_placeholder
            @module.input_placeholder
            (concat "Enter " @module.input_slug)
          }}
          {{if
            @module.input_required
            (htmlSafe '<span class="text-danger">*</span>')
          }}</span>

        {{#if this.disabled}}
          <button
            class="btn btn-sm btn-outline-primary"
            type="button"
            {{on "click" this.initTypeout}}
          >Edit (Typeout)</button>
        {{else}}
          <button
            class="btn btn-sm btn-secondary"
            type="button"
            {{on "click" this.saveTypeout}}
          >Save changes</button>
        {{/if}}
      </div>
    </div>
  </template>
}
