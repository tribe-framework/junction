import Component from '@glimmer/component';
import EditObjectModal from './edit-object-modal.gjs';

export default class TypesListTableComponent extends Component {
  get countListableModules() {
    var count = 0;
    this.args.type.modules.forEach((elem) => {
      if (elem.list_field === true) count++;
    });

    return count;
  }
  <template>
    <div class="overflow-x-scroll">
      <table
        class="table table-striped types-data-table listable-modules-{{this.countListableModules}}"
      >
        {{yield}}
      </table>
    </div>

    {{! This is used only for editing multiple records }}
    <EditObjectModal @multiEdit={{true}} />
  </template>
}
