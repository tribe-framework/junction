import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { Modal } from 'bootstrap';

export default class TypesListTableRowComponent extends Component {
  @service colormodes;
  @service object;
  @service store;

  @tracked isShowing = false;
  @tracked isSelected = false;

  @action
  async showBlueprintObjectModal(tp, id) {
    let o = await this.store.findRecord(tp, id);
    this.object.activateCurrentObject(o);
    this.object.currentType = tp;
    let bp = new Modal(document.getElementById('blueprintObjectModal'), {});
    bp.show();
  }

  isArray(value) {
    return Array.isArray(value);
  }

  isCSV(value) {
    if (typeof value !== 'string') return false;
    // Check if it's a string with comma-separated values
    return (
      value.includes(',') && value.split(',').some((item) => item.trim() !== '')
    );
  }

  split(string, separator) {
    if (typeof string !== 'string') return [];
    return string.split(separator);
  }

  trim(string) {
    if (typeof string !== 'string') return string;
    return string.trim();
  }

  inArray = (needle, haysack) => {
    const index = haysack.indexOf(needle);
    if (index > -1) {
      this.isSelected = true;
      return true;
    } else {
      this.isSelected = false;
      return false;
    }
  };

  @action
  showOptions() {
    document
      .querySelector('#row-options-' + this.args.object.id)
      .classList.remove('d-none');
    document
      .querySelector('#row-options-' + this.args.object.id)
      .classList.add('d-block');
  }

  @action
  hideOptions() {
    document
      .querySelector('#row-options-' + this.args.object.id)
      .classList.add('d-none');
    document
      .querySelector('#row-options-' + this.args.object.id)
      .classList.remove('d-block');
  }

  @action
  toggleSelection() {
    if (this.isSelected === false) {
      document
        .querySelector('#row-' + this.args.object.id)
        .classList.add('bg-info');
      this.isSelected = true;
      this.args.addToSelectedRowIDs(this.args.type.slug, this.args.object.id);
    } else {
      document
        .querySelector('#row-' + this.args.object.id)
        .classList.remove('bg-info');
      this.isSelected = false;
      this.args.removeFromSelectedRowIDs(
        this.args.type.slug,
        this.args.object.id,
      );
    }
  }

  @action
  toggleOptions() {
    if (this.isShowing === false) {
      document
        .querySelector('#row-options-' + this.args.object.id)
        .classList.remove('d-none');
      document
        .querySelector('#row-options-' + this.args.object.id)
        .classList.add('d-block');
      this.isShowing = true;
    } else {
      document
        .querySelector('#row-options-' + this.args.object.id)
        .classList.add('d-none');
      document
        .querySelector('#row-options-' + this.args.object.id)
        .classList.remove('d-block');
      this.isShowing = false;
    }
  }
}
