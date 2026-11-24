import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import eq from 'ember-truth-helpers/helpers/eq';
import { get, concat } from '@ember/helper';
import { Input } from '@ember/component';
import MultiInput from './multi/input.gjs';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';
import not from 'ember-truth-helpers/helpers/not';
import and from 'ember-truth-helpers/helpers/and';
import notEq from 'ember-truth-helpers/helpers/not-eq';
import { on } from '@ember/modifier';

export default class InputFieldsTextComponent extends Component {
  @service object;

  @action
  async generateTitle() {
    let Passphrase = window.Passphrase;
    let passphrase = await Passphrase.generate(36);
    this.args.mutObjectModuleValue(this.args.module.input_slug, passphrase);
  }

  inputType = (type) => {
    if (type === 'number') {
      return 'text';
    }

    return type;
  };

  inputMode = (type) => {
    switch (type) {
      case 'password':
        type = 'text';
        break;

      case 'number':
        type = 'numeric';
        break;

      default:
        break;
    }

    return type;
  };
  <template>
    <div class="mb-3 {{if (eq @module.input_type 'hidden') 'd-none'}}">
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

        <div class="form-text text-end">
          {{if
            @module.input_placeholder
            @module.input_placeholder
            (concat "Enter " @module.input_slug)
          }}
          {{if
            @module.input_required
            (htmlSafe '<span class="text-danger">*</span>')
          }}
        </div>
      {{else}}
        <Input
          id={{concat @type.slug "-" @module.input_slug "-" @id}}
          class="form-control {{if (eq @module.input_type 'hidden') 'd-none'}}"
          placeholder={{@module.input_placeholder}}
          min={{@module.input_min}}
          max={{@module.input_max}}
          inputmode="{{this.inputMode @module.input_type}}"
          autocomplete="off"
          @value={{mut (get @object @module.input_slug)}}
          @type={{this.inputType @module.input_type}}
        />

        <div
          class="form-text text-end
            {{if
              (eq @module.input_type 'hidden')
              'd-none'
              'd-flex w-100 align-items-center justify-content-end'
            }}"
        >
          {{#if @module.input_primary}}
            {{#unless this.object.viaPublicForm}}
              {{#if
                (not (and (get @object @module.input_slug) (notEq @id "new")))
              }}
                <div
                  {{on "click" this.generateTitle}}
                  role="button"
                  class="text-decoration-underline text-end mt-0 cursor-pointer"
                >Generate text</div>
                <div class="mx-1"> or </div>
              {{/if}}
            {{/unless}}
          {{/if}}

          <div>
            {{if
              @module.input_placeholder
              @module.input_placeholder
              (concat "Enter " @module.input_slug)
            }}
            {{if
              @module.input_required
              (htmlSafe '<span class="text-danger">*</span>')
            }}
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
