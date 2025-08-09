import Service from '@ember/service';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';

export default class ObjectService extends Service {
  @tracked currentType = null;
  @tracked currentObject = null;
  @tracked reloadingVars = false;
  @tracked viaPublicForm = false;
  @service type;
  @service types;

  @action
  activateCurrentObject(object) {
    if (object === undefined) {
      this.currentObject = null;
    } else {
      this.currentObject = object;

      //Handling initialisation of multi field
      Object.entries(
        this.types.json.modules[object.modules.type].modules,
      ).forEach((m) => {
        if (m[1].input_multiple === true && m[1].input_multiple) {
          let slug = m[1].input_slug;

          if (typeof this.currentObject.modules[slug] === 'object') {
            this.currentObject.modules[slug] = Object.values(
              this.currentObject.modules[slug]
            );
          } else if (typeof this.currentObject.modules[slug] !== 'array') {
            if (this.currentObject.modules[slug]) {
              let om = this.currentObject.modules[slug];
              this.currentObject.modules[slug] = [];
              this.currentObject.modules[slug].push(om);
            } else this.currentObject.modules[slug] = [];
          }
        }
      });

      this.currentObject = this.currentObject;
    }
  }
}
