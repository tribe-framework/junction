import { Input } from '@ember/component';
import { concat, get } from '@ember/helper';
<template>
  <Input
    id={{concat @type.slug "-" @module.input_slug "-" @id}}
    @value={{mut (get @object @module.input_slug)}}
    @type={{@module.input_type}}
    autocomplete="off"
  />
</template>
