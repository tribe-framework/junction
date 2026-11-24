import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';
import { Textarea } from '@ember/component';
import { on } from '@ember/modifier';
import { concat } from '@ember/helper';

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
  <template>
    {{#if this.object.currentObject}}
      <div class="mb-3">
        <div class="card px-0">

          <div class="card-header border-0 text-uppercase">
            <i class="fa-solid fa-file-code"></i>
            <span class="ms-1">{{if
                @module.input_placeholder
                @module.input_placeholder
                "Storylang Stack"
              }}
              {{if
                @module.input_required
                (htmlSafe '<span class="text-danger">*</span>')
              }}</span>
          </div>

          <div
            class="card-body px-3 mx-0 overflow-y-scroll overflow-x-hidden"
            style="height:40vh;"
          >
            <div class="my-3">
              <Textarea
                @value={{this.object.currentObject.modules.storylang_stack.platformDescription}}
                placeholder="Describe your platform for AI to generate your initial codebase architecture"
                class="form-control border border-1 border-primary"
                rows="6"
                {{on "change" this.updateObject}}
              />
              <button
                class="btn btn-sm btn-primary mt-2"
                type="button"
                {{on "click" this.getAI}}
              >Generate platform map using AI</button>
            </div>
          </div>

          <div class="card-footer border-0">
          </div>

        </div>

        <div class="form-text text-end">{{if
            @module.input_placeholder
            @module.input_placeholder
            (concat "Enter " @module.input_slug)
          }}</div>
      </div>
    {{/if}}
  </template>
}
