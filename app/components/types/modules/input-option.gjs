import Component from '@glimmer/component';
import { service } from '@ember/service';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { Input } from '@ember/component';
import { get, fn } from '@ember/helper';
import { on } from '@ember/modifier';
import onClickOutside from 'ember-click-outside/modifiers/on-click-outside';
import onKey from 'ember-keyboard/modifiers/on-key';
import eq from 'ember-truth-helpers/helpers/eq';

export default class TypesModulesInputOptionComponent extends Component {
  @service module;

  @tracked clickedOutside = true;

  convertToSlug = (Text) => {
    return Text.toLowerCase()
      .replace(/ /g, '_')
      .replace(/[^\w-]+/g, '')
      .replace(/-/g, '_');
  };

  @tracked option =
    this.args.option !== undefined ? this.args.option : { title: '', slug: '' };

  @action
  validateOption(e) {
    if (this.clickedOutside === false) {
      this.clickedOutside = true;
      if (this.option.title || this.option.slug) {
        if (!this.option.slug) {
          this.option.slug = this.convertToSlug(this.option.title);
        }
        if (!this.option.title) {
          this.option.title = this.option.slug;
        }
        this.option = this.option;

        this.module.updateOption(this.option);
      }
    }
  }

  @action
  clickedInside() {
    this.clickedOutside = false;
  }
  <template>
    <div class="input-group mb-3">
      <Input
        @type="text"
        class="form-control"
        placeholder="Option title"
        @value={{mut (get this.option "title")}}
        {{on "focus" this.clickedInside}}
        {{onClickOutside this.validateOption}}
        {{onKey "Tab" this.validateOption}}
        {{onKey "Enter" this.validateOption}}
      />

      {{#if (get this.option "title")}}
        <Input
          @type="text"
          class="form-control"
          placeholder="Option value"
          @value={{mut (get this.option "slug")}}
          {{on "focus" this.clickedInside}}
          {{onClickOutside this.validateOption}}
          {{onKey "Tab" this.validateOption}}
          {{onKey "Enter" this.validateOption}}
        />
      {{/if}}

      {{#if (eq @index 0)}}
        <span class="input-group-text" {{on "click" this.module.addOption}}><i
            class="fa-solid fa-circle-plus"
          ></i></span>
      {{else}}
        <span
          class="input-group-text text-danger"
          {{on "click" (fn this.module.removeOption @index)}}
        ><i class="fa-solid fa-circle-xmark"></i></span>
      {{/if}}
    </div>
  </template>
}
