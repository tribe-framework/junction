import Component from '@glimmer/component';
import { service } from '@ember/service';
import InputOption from './input-option.gjs';

export default class TypesModulesInputOptionsComponent extends Component {
  @service module;
  <template>
    {{#each this.module.inputOptions as |option index|}}
      <InputOption @index={{index}} @option={{option}} />
    {{else}}
      <InputOption @index={{0}} />
    {{/each}}

    {{! "input_options":[{"slug":"admin","title":"Admin"},{"slug":"organisation_employee","title":"Organisation Employee"},{"slug":"community_leader","title":"Community Leader"} }}
  </template>
}
