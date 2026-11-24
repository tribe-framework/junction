import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { A } from '@ember/array';
import { service } from '@ember/service';
import { action } from '@ember/object';
import PowerSelect from 'ember-power-select/components/power-select';

export default class TypesListTablePageLengthSelectorComponent extends Component {
  @tracked options = A(['5', '10', '25', '50', '100', '250', '500']);
  @tracked selectedOption = '25';

  @service colormodes;

  @action
  updatePageLength(e) {
    this.selectedOption = e;
    this.args.updatePageLength(e);
  }
  <template>
    <PowerSelect
      class="form-control border-{{this.colormodes.inverseMode}}"
      @placeholder="Number of resulsts per page"
      @sec=""
      @options={{this.options}}
      @onChange={{this.updatePageLength}}
      @selected={{this.selectedOption}}
      as |opt|
    >
      {{opt}}
      results per page
    </PowerSelect>
  </template>
}
