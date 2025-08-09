import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';

export default class InputFieldsStorylangStack extends Component {
  @service object;
  @service colormodes;
  @service types;
  @service type;

  @action
  updateObject() {
    this.args.mutObjectModuleValue(this.args.module.input_slug, this.obj);
  }

  get obj() {
    if (
      this.object.currentObject &&
      this.object.currentObject.modules &&
      this.object.currentObject.modules.storylang_stack
    ) {
      return {
        platformDescription:
          this.object.currentObject.modules.storylang_stack.platformDescription,
      };
    } else {
      return {
        platformDescription:
          this.types.json.modules.webapp.project_description ?? '',
      };
    }
  }

  @action
  async getAI() {
    if (
      this.object.currentObject.modules.storylang_stack.platformDescription !=
      ''
    ) {
      console.log(
        this.object.currentObject.modules.storylang_stack.platformDescription,
      );
      console.log(this.types.simplifiedJson);
      this.type.loadingSearchResults = true;
      let response = await fetch(
        'https://tribe.junction.express/custom/anthropic/get-storylang.php',
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            platform_description:
              this.object.currentObject.modules.storylang_stack
                .platformDescription,
            simplified_types: this.types.simplifiedJson,
          }),
        },
      );
      let data = await response.json();

      if (data !== undefined && data && data.json) {
        let data_json = data.json;
        console.log(data_json);
      }
      this.type.loadingSearchResults = false;
    }
  }
}
