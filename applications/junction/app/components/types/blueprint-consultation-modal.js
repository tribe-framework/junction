import Component from '@glimmer/component';
import { service } from '@ember/service';
import { Modal } from 'bootstrap';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';

export default class TypesBlueprintConsultationModalComponent extends Component {
  @service types;

  @action
  initModel() {
    if (this.types.json.modules.webapp.implementation_summary) {
      if (!this.types.json.modules.webapp.implementation_summary.seen) {
        this.types.json.modules.webapp.implementation_summary.seen = true;
        this.types.json.save();
      }
      
      let m = new Modal(
        document.getElementById('blueprintConsultationModal'),
        {},
      );
      m.show();
    }
  }
}
