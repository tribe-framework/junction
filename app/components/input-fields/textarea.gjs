import { get, concat } from '@ember/helper';
import MultiInput from './multi/input.gjs';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';
import { Textarea } from '@ember/component';
<template>
  <div class="mb-3">
    {{#if @module.input_multiple}}
      {{#each (get @object @module.input_slug) as |field index|}}
        <MultiInput
          @isTextarea={{true}}
          @mutObjectModuleValue={{@mutObjectModuleValue}}
          @type={{@type}}
          @module={{@module}}
          @id={{@id}}
          @object={{@object}}
          @addToMultiField={{@addToMultiField}}
          @removeFromMultiField={{@removeFromMultiField}}
          @index={{index}}
        />
      {{else}}
        <MultiInput
          @isTextarea={{true}}
          @mutObjectModuleValue={{@mutObjectModuleValue}}
          @type={{@type}}
          @module={{@module}}
          @id={{@id}}
          @object={{@object}}
          @addToMultiField={{@addToMultiField}}
          @removeFromMultiField={{@removeFromMultiField}}
          @index={{0}}
        />
      {{/each}}
      <div class="form-text text-end">{{if
          @module.input_placeholder
          @module.input_placeholder
          (concat "Enter " @module.input_slug)
        }}
        {{if
          @module.input_required
          (htmlSafe '<span class="text-danger">*</span>')
        }}</div>
    {{else}}
      <Textarea
        id={{concat @type.slug "-" @module.input_slug "-" @id}}
        @value={{mut (get @object @module.input_slug)}}
        class="form-control"
        placeholder={{@module.input_placeholder}}
        autocomplete="off"
      />
      <div class="form-text text-end">{{if
          @module.input_placeholder
          @module.input_placeholder
          (concat "Enter " @module.input_slug)
        }}
        {{if
          @module.input_required
          (htmlSafe '<span class="text-danger">*</span>')
        }}</div>
    {{/if}}
  </div>
</template>
