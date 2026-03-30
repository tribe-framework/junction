import Service from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { later } from '@ember/runloop';
import { service } from '@ember/service';
import { Modal } from 'bootstrap';

export default class BlueprintsService extends Service {
  @service colormodes;
  @service types;
  @service store;
  @service type;
  @service auth;

  @tracked myBlueprints = [];

  @action
  async downloadCurrentBlueprint() {
    this.type.loadingSearchResults = true;

    let j = this.types.json.modules;

    var types_json = [];
    Object.entries(j).forEach((v) => {
      let type_slug = v[0];
      let type_obj = v[1];

      if (
        type_slug != 'deleted_record' &&
        type_slug != 'platform_record' &&
        type_slug != 'blueprint_record' &&
        type_slug != 'file_record' &&
        type_slug != 'apikey_record'
      ) {
        types_json[type_slug] = type_obj;
      }
    });

    later(
      this,
      () => {
        const jsonString = JSON.stringify(
          Object.fromEntries(Object.entries(types_json)),
          null,
          2,
        );

        const blob = new Blob([jsonString], { type: 'application/json' });
        let t = Math.floor(new Date().getTime() / 1000);

        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'Blueprint-' + t + '.types.json';

        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        this.type.loadingSearchResults = false;
      },
      1000,
    );
  }

  @action
  async downloadCurrentSimplifiedBlueprint() {
    this.type.loadingSearchResults = true;

    let types_json = this.types.simplifiedJson;

    later(
      this,
      () => {
        const jsonString = JSON.stringify(
          Object.fromEntries(Object.entries(types_json)),
          null,
          2,
        );

        const blob = new Blob([jsonString], { type: 'application/json' });
        let t = Math.floor(new Date().getTime() / 1000);

        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'Blueprint-' + t + '.simplified-types.json';

        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        this.type.loadingSearchResults = false;
      },
      1000,
    );
  }

  @action
  async changeBlueprint(blueprint) {
    if (!blueprint || blueprint.modules === undefined) return;

    const types_json = blueprint.modules.types_json;
    if (!types_json) return;

    this.type.loadingSearchResults = true;

    // Preserve the current webapp config, apply the blueprint's type definitions
    var current_webapp = {};
    Object.entries(this.types.json.modules).forEach((v) => {
      if (v[0] === 'webapp') current_webapp['webapp'] = v[1];
    });

    this.types.json.modules = {
      ...Object.assign({}, current_webapp),
      ...Object.assign({}, types_json),
    };

    await this.types.json.save();
    window.location.href = '/';
  }

  @action
  async clearBlueprint() {
    var userResponse = confirm(
      'Are you sure you want to clear the blueprint? This will remove all your tracks. This does not affect the data saved. You can undo this step.',
    );

    if (userResponse) {
      this.type.loadingSearchResults = true;

      var types_json = [];
      Object.entries(this.types.json.modules).forEach((v) => {
        if (v[0] === 'webapp') types_json['webapp'] = v[1];
      });

      types_json['webapp']['implementation_summary'] = '';
      types_json['webapp']['project_description'] = '';

      this.types.json.modules = { ...Object.assign({}, types_json) };
      await this.types.json.save();
      window.location.href = '/';
    }
  }

  @action
  async getBlueprints() {
    this.myBlueprints = await this.store.query('blueprint_record', {
      show_public_objects_only: false,
    });
  }
}
