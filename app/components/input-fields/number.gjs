import { get, concat } from '@ember/helper';
import { Input } from '@ember/component';
import MultiInput from './multi/input.gjs';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';
<template>
  <div class="mb-3">
    {{#if @module.input_multiple}}
      {{#each (get @object @module.input_slug) as |field index|}}
        <MultiInput
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
        min={{@module.input_min}}
        max={{@module.input_max}}
        class="form-control"
        placeholder={{@module.input_placeholder}}
        autocomplete="off"
      />
      <div class="form-text text-end">{{@module.input_placeholder}}
        {{if
          @module.input_required
          (htmlSafe '<span class="text-danger">*</span>')
        }}</div>
    {{/if}}
  </div>
</template>
