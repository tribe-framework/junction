import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';
import { Input, Textarea } from '@ember/component';
import { concat, fn } from '@ember/helper';
import { on } from '@ember/modifier';
import XToggle from '../x-toggle.gjs';

export default class InputFieldsVisualGuide extends Component {
  @service object;
  @service colormodes;

  @action
  updateObject() {
    this.args.mutObjectModuleValue(this.args.module.input_slug, this.obj);
  }

  @action
  copySCSS() {
    // Create a temporary textarea to handle the copying
    const tempTextArea = document.createElement('textarea');
    tempTextArea.value = this.scss;
    document.body.appendChild(tempTextArea);
    tempTextArea.select();

    try {
      // Execute copy command
      document.execCommand('copy');
      // Show a temporary success visual feedback (could be improved with a toast/notification)
      const copyButton = event.currentTarget;
      const originalText = copyButton.innerHTML;
      copyButton.innerHTML = '<i class="fa-solid fa-check"></i> Copied!';
      setTimeout(() => {
        copyButton.innerHTML = originalText;
      }, 2000);
    } catch (err) {
      console.error('Failed to copy text: ', err);
    }

    // Clean up
    document.body.removeChild(tempTextArea);
  }

  get obj() {
    if (
      this.object.currentObject &&
      this.object.currentObject.modules &&
      this.object.currentObject.modules.visual_guide
    ) {
      return {
        colorPrimary:
          this.object.currentObject.modules.visual_guide.colorPrimary,
        colorSecondary:
          this.object.currentObject.modules.visual_guide.colorSecondary,
        colorSuccess:
          this.object.currentObject.modules.visual_guide.colorSuccess,
        colorInfo: this.object.currentObject.modules.visual_guide.colorInfo,
        colorWarning:
          this.object.currentObject.modules.visual_guide.colorWarning,
        colorDanger: this.object.currentObject.modules.visual_guide.colorDanger,
        colorDark: this.object.currentObject.modules.visual_guide.colorDark,
        colorLight: this.object.currentObject.modules.visual_guide.colorLight,
        isRounded: this.object.currentObject.modules.visual_guide.isRounded,
        importFontURL1:
          this.object.currentObject.modules.visual_guide.importFontURL1,
        importFontURL2:
          this.object.currentObject.modules.visual_guide.importFontURL2,
        fontFamily1: this.object.currentObject.modules.visual_guide.fontFamily1,
        fontFamily2: this.object.currentObject.modules.visual_guide.fontFamily2,
      };
    } else {
      return {
        colorPrimary: '#000000',
        colorSecondary: '#cccccc',
        colorSuccess: '#00ff00',
        colorInfo: '#0000ff',
        colorWarning: '#ffff00',
        colorDanger: '#ff0000',
        colorDark: '#333333',
        colorLight: '#eeeeee',
        isRounded: false,
        importFontURL1:
          'https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,500;1,600;1,700&display=swap',
        importFontURL2: '',
        fontFamily1: '"IBM Plex Mono", serif',
        fontFamily2: '"IBM Plex Mono", serif',
      };
    }
  }

  get scss() {
    let font1 = '';
    if (this.obj.importFontURL1) {
      font1 = `@import url('${this.obj.importFontURL1}');`;
    }

    let font2 = '';
    if (this.obj.importFontURL2) {
      font2 = `
@import url('${this.obj.importFontURL2}');`;
    }

    return (
      font1 +
      font2 +
      `

$font-family-sans-serif: ${this.obj.fontFamily1} !default;
$display-font-family: ${this.obj.fontFamily2} !default;

$primary: ${this.obj.colorPrimary} !default;
$secondary: ${this.obj.colorSecondary} !default;
$info: ${this.obj.colorInfo} !default;
$success: ${this.obj.colorSuccess} !default;
$warning: ${this.obj.colorWarning} !default;
$danger: ${this.obj.colorDanger} !default;
$light: ${this.obj.colorDark} !default;
$dark: ${this.obj.colorLight} !default;

$enable-rounded: ${this.obj.isRounded} !default;
$enable-negative-margins: true !default;
$enable-cssgrid: true !default;

$spacer: 1rem !default;
$spacers: (
  0: 0,
  1: $spacer * .25,
  2: $spacer * .5,
  3: $spacer,
  4: $spacer * 1.5,
  5: $spacer * 3,
  6: $spacer * 4.5,
  7: $spacer * 6,
  8: $spacer * 7.5,
  9: $spacer * 9,
  10: $spacer * 12,
) !default;

@import "node_modules/bootstrap/scss/bootstrap";
@import "node_modules/animate.css/animate";
	    `
    );
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
                "Visual Guide"
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
            <div class="row">
              <div class="col-6 my-3">
                <Input
                  id={{concat
                    @type.slug
                    "-"
                    @module.input_slug
                    "-"
                    @id
                    "-color-primary"
                  }}
                  @value={{this.obj.colorPrimary}}
                  @type="color"
                  class="form-control"
                  placeholder
                  autocomplete="off"
                  {{on "change" this.updateObject}}
                />
                <div class="form-text text-end">Primary Colour</div>
              </div>
              <div class="col-6 my-3">
                <Input
                  id={{concat
                    @type.slug
                    "-"
                    @module.input_slug
                    "-"
                    @id
                    "-color-secondary"
                  }}
                  @value={{this.obj.colorSecondary}}
                  @type="color"
                  class="form-control"
                  placeholder
                  autocomplete="off"
                  {{on "change" this.updateObject}}
                />
                <div class="form-text text-end">Secondary Colour</div>
              </div>
              <div class="col-6 my-3">
                <Input
                  id={{concat
                    @type.slug
                    "-"
                    @module.input_slug
                    "-"
                    @id
                    "-color-info"
                  }}
                  @value={{this.obj.colorInfo}}
                  @type="color"
                  class="form-control"
                  placeholder
                  autocomplete="off"
                  {{on "change" this.updateObject}}
                />
                <div class="form-text text-end">Info Colour</div>
              </div>
              <div class="col-6 my-3">
                <Input
                  id={{concat
                    @type.slug
                    "-"
                    @module.input_slug
                    "-"
                    @id
                    "-color-success"
                  }}
                  @value={{this.obj.colorSuccess}}
                  @type="color"
                  class="form-control"
                  placeholder
                  autocomplete="off"
                  {{on "change" this.updateObject}}
                />
                <div class="form-text text-end">Success Colour</div>
              </div>
              <div class="col-6 my-3">
                <Input
                  id={{concat
                    @type.slug
                    "-"
                    @module.input_slug
                    "-"
                    @id
                    "-color-warning"
                  }}
                  @value={{this.obj.colorWarning}}
                  @type="color"
                  class="form-control"
                  placeholder
                  autocomplete="off"
                  {{on "change" this.updateObject}}
                />
                <div class="form-text text-end">Warning Colour</div>
              </div>
              <div class="col-6 my-3">
                <Input
                  id={{concat
                    @type.slug
                    "-"
                    @module.input_slug
                    "-"
                    @id
                    "-color-danger"
                  }}
                  @value={{this.obj.colorDanger}}
                  @type="color"
                  class="form-control"
                  placeholder
                  autocomplete="off"
                  {{on "change" this.updateObject}}
                />
                <div class="form-text text-end">Danger Colour</div>
              </div>
              <div class="col-6 my-3">
                <Input
                  id={{concat
                    @type.slug
                    "-"
                    @module.input_slug
                    "-"
                    @id
                    "-color-dark"
                  }}
                  @value={{this.obj.colorDark}}
                  @type="color"
                  class="form-control"
                  placeholder
                  autocomplete="off"
                  {{on "change" this.updateObject}}
                />
                <div class="form-text text-end">Dark Colour</div>
              </div>
              <div class="col-6 my-3">
                <Input
                  id={{concat
                    @type.slug
                    "-"
                    @module.input_slug
                    "-"
                    @id
                    "-color-light"
                  }}
                  @value={{this.obj.colorLight}}
                  @type="color"
                  class="form-control"
                  placeholder
                  autocomplete="off"
                  {{on "change" this.updateObject}}
                />
                <div class="form-text text-end">Light Colour</div>
              </div>
            </div>

            {{! Font Input Fields Start }}
            <div class="my-3">
              <Input
                id={{concat
                  @type.slug
                  "-"
                  @module.input_slug
                  "-"
                  @id
                  "-import-font-url1"
                }}
                @value={{this.obj.importFontURL1}}
                @type="text"
                class="form-control"
                placeholder="Enter Font URL"
                autocomplete="off"
                {{on "change" this.updateObject}}
              />
              <div class="form-text text-end">Import Font URL 1</div>
            </div>

            <div class="my-3">
              <Input
                id={{concat
                  @type.slug
                  "-"
                  @module.input_slug
                  "-"
                  @id
                  "-import-font-url2"
                }}
                @value={{this.obj.importFontURL2}}
                @type="text"
                class="form-control"
                placeholder="Enter Font URL"
                autocomplete="off"
                {{on "change" this.updateObject}}
              />
              <div class="form-text text-end">Import Font URL 2</div>
            </div>

            <div class="my-3">
              <Input
                id={{concat
                  @type.slug
                  "-"
                  @module.input_slug
                  "-"
                  @id
                  "-font-family1"
                }}
                @value={{this.obj.fontFamily1}}
                @type="text"
                class="form-control"
                placeholder="Enter Font Family"
                autocomplete="off"
                {{on "change" this.updateObject}}
              />
              <div class="form-text text-end">Font Family 1</div>
            </div>

            <div class="my-3">
              <Input
                id={{concat
                  @type.slug
                  "-"
                  @module.input_slug
                  "-"
                  @id
                  "-font-family2"
                }}
                @value={{this.obj.fontFamily2}}
                @type="text"
                class="form-control"
                placeholder="Enter Font Family"
                autocomplete="off"
                {{on "change" this.updateObject}}
              />
              <div class="form-text text-end">Font Family 2</div>
            </div>
            {{! Font Input Fields End }}

            <div class="my-3 d-flex align-items-center justify-content-start">
              <div class=""><XToggle
                  @value={{this.object.currentObject.modules.visual_guide.isRounded}}
                  @onToggle={{fn
                    (mut
                      this.object.currentObject.modules.visual_guide.isRounded
                    )
                  }}
                  @theme="ios"
                  @variant={{this.colormodes.mode}}
                /></div>
              <div class="form-text text-end ms-4">Is rounded?</div>
            </div>

            <div class="mt-5 position-relative">
              <Textarea
                readonly
                @value={{this.scss}}
                class="form-control border border-1 border-primary"
                rows="6"
                id="scss-textarea"
              />
              <button
                type="button"
                class="btn btn-sm btn-primary position-absolute"
                style="top: 10px; right: 10px;"
                {{on "click" this.copySCSS}}
              >
                <i class="fa-solid fa-copy"></i>
                Copy
              </button>
              <div class="form-text text-end">app.scss</div>
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
