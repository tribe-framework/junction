import { on } from '@ember/modifier';
import { fn } from '@ember/helper';

const toggle = (onToggle, event) => onToggle?.(event.target.checked);

<template>
  <div
    class="form-check form-switch m-0 {{if (isSmall @size) 'small'}}"
    ...attributes
  >
    <input
      class="form-check-input"
      type="checkbox"
      role="switch"
      checked={{@value}}
      disabled={{@disabled}}
      {{on "change" (fn toggle @onToggle)}}
    />
  </div>
</template>

function isSmall(size) {
  return size === 'small';
}
