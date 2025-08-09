import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { Modal } from 'bootstrap';
import { later } from '@ember/runloop';

export default class TypesListTableRowOptionsComponent extends Component {
  isLastSlashOrEquals = (id) => {
    let last = id.substr(id.length - 1);
    if (last == '/' || last == '=') return true;
    else return false;
  };

  @service object;
  @service type;
  @service colormodes;
  @service blueprints;

  @action
  openBlueprintModal() {
    this.object.activateCurrentObject(this.args.object);
    this.object.currentType = this.args.type;
    let bp = new Modal(document.getElementById('blueprintObjectModal'), {});
    bp.show();
  }

  @action
  openEditModal() {
    this.object.reloadingVars = true;
    this.object.activateCurrentObject(this.args.object);
    this.object.currentType = this.args.type;
    this.object.reloadingVars = false;
    let bp = new Modal(document.getElementById('editObjectModal'), {});
    bp.show();
  }

  @action
  openCopyModal() {
    this.object.reloadingVars = true;
    this.object.activateCurrentObject(this.args.object);
    this.object.currentType = this.args.type;
    this.object.reloadingVars = false;
    let bp = new Modal(document.getElementById('copyObjectModal'), {});
    bp.show();
  }

  @action
  async restoreRecord() {
    this.object.activateCurrentObject(this.args.object);
    this.object.currentObject.type = this.args.object.modules.deleted_type;
    this.object.currentObject.modules.type =
      this.args.object.modules.deleted_type;
    this.args.object.modules.deleted_type = '';
    await this.object.currentObject.save();
    this.type.search();
  }
}
