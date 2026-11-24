import { Textarea } from '@ember/component';
import { concat, get } from '@ember/helper';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';
<template>
  <div class="mb-3">
    <Textarea
      id={{concat @type.slug "-" @module.input_slug "-" @id}}
      @value={{mut (get @object @module.input_slug)}}
      class="form-control"
      placeholder={{@module.input_placeholder}}
      autocomplete="off"
    />
    <div class="form-text text-end">{{@module.input_placeholder}}
      {{if
        @module.input_required
        (htmlSafe '<span class="text-danger">*</span>')
      }}</div>
  </div>
</template>
