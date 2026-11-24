import Component from '@glimmer/component';
import { service } from '@ember/service';
import XToggle from '../x-toggle.gjs';
import { get, fn, concat } from '@ember/helper';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';

export default class InputFieldsCheckboxComponent extends Component {
  @service colormodes;
  <template>
    <div class="mb-5 d-flex align-items-center justify-content-start">
      <div class=""><XToggle
          @value={{get @object @module.input_slug}}
          @onToggle={{fn (mut (get @object @module.input_slug))}}
          @theme="ios"
          @variant={{this.colormodes.mode}}
        /></div>
      <div class="form-text text-end ms-4">{{if
          @module.input_placeholder
          @module.input_placeholder
          (concat "Choose " @module.input_slug)
        }}
        {{if
          @module.input_required
          (htmlSafe '<span class="text-danger">*</span>')
        }}</div>
    </div>
  </template>
}
