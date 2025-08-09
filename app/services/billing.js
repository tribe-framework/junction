import Service from '@ember/service';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import ENV from 'junction/config/environment';
import { later } from '@ember/runloop';

export default class BillingService extends Service {
  @service types;

  get totalObjects() {
    return this.types.json.modules.webapp.total_objects;
  }

  get sizeInGB() {
    return this.types.json.modules.webapp.size_in_gb;
  }
}
