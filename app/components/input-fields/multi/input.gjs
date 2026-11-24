import Component from '@glimmer/component';
import { service } from '@ember/service';
import { Textarea, Input } from '@ember/component';
import { get, concat, fn } from '@ember/helper';
import eq from 'ember-truth-helpers/helpers/eq';
import { on } from '@ember/modifier';
import notEq from 'ember-truth-helpers/helpers/not-eq';

export default class InputFieldsMultiInput extends Component {
  @service object;

  get lengthMinusOne() {
    if (
      this.object.currentObject === null ||
      this.object.currentObject.modules[this.args.module.input_slug] ===
        undefined
    )
      return 0;
    else
      return (
        this.object.currentObject.modules[this.args.module.input_slug].length -
        1
      );
  }
  <template>
    <div class="input-group">

      {{#if @isTextarea}}

        <Textarea
          @value={{mut
            (get
              (get this.object.currentObject.modules @module.input_slug) @index
            )
          }}
          name="{{@type.slug}}-{{@module.input_slug}}-{{@id}}[]"
          class="form-control"
          placeholder={{concat "[" @index "] " @module.input_placeholder}}
          autocomplete="off"
        />

      {{else}}

        <Input
          @value={{mut
            (get
              (get this.object.currentObject.modules @module.input_slug) @index
            )
          }}
          @type={{@module.input_type}}
          name="{{@type.slug}}-{{@module.input_slug}}-{{@id}}[]"
          class="form-control {{if (eq @module.input_type 'hidden') 'd-none'}}"
          placeholder={{concat "[" @index "] " @module.input_placeholder}}
          min={{@module.input_min}}
          max={{@module.input_max}}
          autocomplete="off"
        />

      {{/if}}

      {{#if (eq @index 0)}}
        <span
          class="input-group-text"
          {{on "click" (fn @addToMultiField @module.input_slug @index)}}
        ><i class="fa-solid fa-circle-plus"></i></span>
      {{/if}}

      {{#if (notEq @index 0)}}
        <span
          class="input-group-text text-danger"
          {{on "click" (fn @removeFromMultiField @module.input_slug @index)}}
        ><i class="fa-solid fa-circle-xmark"></i></span>
      {{/if}}

    </div>
  </template>
}
