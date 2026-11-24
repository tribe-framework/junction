import Component from '@glimmer/component';
import { action } from '@ember/object';
import { v4 as uuidv4 } from 'uuid';
import { get, concat } from '@ember/helper';
import { Input } from '@ember/component';
import MultiInput from './multi/input.gjs';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';
import { on } from '@ember/modifier';

export default class InputFieldsUuidV4 extends Component {
  @action
  generateUUIDv4() {
    this.args.mutObjectModuleValue(this.args.module.input_slug, uuidv4());
  }
  <template>
    <div class="mb-3">
      {{#if @module.input_multiple}}
        {{#each (get @object @module.input_slug) as |field index|}}
          {{#if field}}
            <MultiInput
              @mutObjectModuleValue={{@mutObjectModuleValue}}
              @type="text"
              @module={{@module}}
              @id={{@id}}
              @object={{@object}}
              @addToMultiField={{@addToMultiField}}
              @removeFromMultiField={{@removeFromMultiField}}
              @index={{index}}
            />
          {{/if}}
        {{else}}
          <MultiInput
            @mutObjectModuleValue={{@mutObjectModuleValue}}
            @type="text"
            @module={{@module}}
            @id={{@id}}
            @object={{@object}}
            @addToMultiField={{@addToMultiField}}
            @removeFromMultiField={{@removeFromMultiField}}
            @index={{0}}
          />
        {{/each}}
        <div class="form-text text-end">{{@module.input_placeholder}}
          {{if
            @module.input_required
            (htmlSafe '<span class="text-danger">*</span>')
          }}</div>
      {{else}}
        <Input
          id={{concat @type.slug "-" @module.input_slug "-" @id}}
          @value={{mut (get @object @module.input_slug)}}
          @type={{@module.input_type}}
          class="form-control"
          placeholder={{@module.input_placeholder}}
          autocomplete="off"
        />

        <div
          class="form-text text-end d-flex w-100 align-items-center justify-content-end"
        >
          <div
            {{on "click" this.generateUUIDv4}}
            role="button"
            class="text-decoration-underline text-end mt-0 cursor-pointer"
          >Generate</div>
          <div class="mx-1"> or </div>
          <div>{{@module.input_placeholder}}</div>
          {{if
            @module.input_required
            (htmlSafe '<span class="text-danger">*</span>')
          }}</div>
      {{/if}}
    </div>
  </template>
}
