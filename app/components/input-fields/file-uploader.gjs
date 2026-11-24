import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { Queue } from 'ember-file-upload';
import ENV from 'junction/config/environment';
import fileUrl from '../../helpers/file-url';
import { later } from '@ember/runloop';
import htmlSafe from 'ember-cli-string-helpers/helpers/html-safe';
import { on } from '@ember/modifier';
import { fn, concat, get } from '@ember/helper';
import fileQueue from 'ember-file-upload/helpers/file-queue';
import FileDropzone from 'ember-file-upload/components/file-dropzone';

export default class InputFieldsFileUploaderComponent extends Component {
  isString = (object) => {
    return typeof object === 'string' ? true : false;
  };

  explodeFilename = (filename) => {
    var myarr = filename.split('/uploads/');
    return myarr[1];
  };

  @service fileQueue;
  @service store;
  @service colormodes;

  get queue() {
    return this.fileQueue.findOrCreate(
      this.args.type.slug +
        '-' +
        this.args.module.input_slug +
        '-' +
        this.args.id,
    );
  }

  @action
  triggerSelectFile(e) {
    document.querySelector('#' + e).click();
  }

  @action
  async uploadFile(file) {
    try {
      const response = await file.upload(ENV.TribeENV.API_URL + '/uploads.php');
      response.json().then(async (data) => {
        if (data.status == 'success') {
          let files = this.args.object[this.args.module.input_slug] ?? [];
          files.push(data.file);
          this.args.mutObjectModuleValue(this.args.module.input_slug, files);

          let obj = this.store.createRecord('file_record', {
            modules: {
              title: data.file.name,
              mime: data.file.mime,
              url: data.file.url,
              file: data.file,
              content_privacy: 'private',
            },
          });
          await obj.save();
        } else if (data.status == 'error') {
          alert(data.error_message);
        }
      });
    } catch (error) {
      file.state = 'aborted';
    }
  }

  @action
  deleteFile(index) {
    let files = this.args.object[this.args.module.input_slug] ?? [];
    if (index > -1) {
      files.splice(index, 1);
    }
    this.args.mutObjectModuleValue(this.args.module.input_slug, files);
  }

  @action
  copyLink(text, index) {
    document.querySelector('#copy-' + index).innerHTML = 'Copied!';

    navigator.clipboard.writeText(text);

    later(
      this,
      () => {
        document.querySelector('#copy-' + index).innerHTML = 'Copy link';
      },
      2000,
    );
  }
  <template>
    <div class="mb-3"><div class="card px-0">

        <div class="card-header border-0 text-uppercase">
          <i class="fa-solid fa-file-import"></i>
          <span class="ms-1">{{if
              @module.input_placeholder
              @module.input_placeholder
              "File Uploader"
            }}
            {{if
              @module.input_required
              (htmlSafe '<span class="text-danger">*</span>')
            }}</span>
        </div>

        <div
          class="card-body p-0"
          {{on
            "click"
            (fn
              this.triggerSelectFile
              (concat @type.slug "-" @module.input_slug "-" @id "-uploader")
            )
          }}
        >

          {{#let
            (fileQueue
              name=(concat @type.slug "/" @module.input_slug "/" @id)
              onFileAdded=this.uploadFile
            )
            as |queue|
          }}
            <div class="d-none">
              <input
                class="form-control"
                type="file"
                id="{{concat
                  @type.slug
                  '-'
                  @module.input_slug
                  '-'
                  @id
                  '-uploader'
                }}"
                {{queue.selectFile}}
              />
            </div>
            <FileDropzone @queue={{queue}} as |dropzone|>
              {{#if dropzone.active}}
                <div
                  class="text-center w-100 fs-4 p-3"
                  style="border: 2px dashed #000;"
                ><i
                    class="fa-solid fa-wand-magic-sparkles fa-spin"
                  ></i>&nbsp;&nbsp;Drop to upload</div>
              {{else if queue.files.length}}
                <div
                  class="text-center w-100 fs-4 p-3"
                  style="border: 2px dashed #eee;"
                ><i class="fa-solid fa-clock"></i>&nbsp;Uploading
                  {{queue.files.length}}
                  file(s) ({{queue.progress}}% done).</div>
                <div
                  class="progress"
                  role="progressbar"
                  aria-valuenow="{{queue.progress}}"
                  aria-valuemin="0"
                  aria-valuemax="100"
                >
                  <div
                    class="progress-bar progress-bar-striped progress-bar-animated"
                    style="width: {{queue.progress}}%"
                  ></div>
                </div>
              {{else if dropzone.supported}}
                <div
                  class="text-center text-muted w-100 fs-4 p-3"
                  style="border: 2px dashed #eee;"
                ><i class="fa-solid fa-cloud-arrow-up"></i>&nbsp;&nbsp;Drag and
                  drop files here to upload them</div>
              {{/if}}
            </FileDropzone>
          {{/let}}

        </div>

        <div class="card-footer border-0" style="overflow-x: scroll;">
          {{#each (get @object @module.input_slug) as |file index|}}
            {{#if (this.isString file)}}

              <div class="my-1 d-flex align-items-center justify-content-start">
                <a
                  href="{{fileUrl file}}"
                  class="me-2 btn btn-sm btn-outline-{{this.colormodes.inverseMode}}"
                  target="new"
                >View file <i class="fa-solid fa-up-right-from-square"></i></a>
                <button
                  {{on "click" (fn this.copyLink (fileUrl file) index)}}
                  type="button"
                  class="me-2 btn btn-sm btn-outline-{{this.colormodes.inverseMode}}"
                  target="new"
                ><span id="copy-{{index}}">Copy link</span>
                  <i class="fa-solid fa-copy"></i></button>
                <span
                  class="me-3 text-danger cursor-pointer"
                  {{on "click" (fn this.deleteFile index)}}
                ><i class="fa-solid fa-circle-xmark"></i></span>
                <span class="text-muted">{{this.explodeFilename file}}</span>
              </div>

            {{else}}

              <div class="my-1 d-flex align-items-center justify-content-start">

                {{#if file.cloudflare_stream}}

                  {{#if
                    (get (get file.cloudflare_stream "result") "thumbnail")
                  }}
                    <div class="me-2"><img
                        src="{{get
                          (get file.cloudflare_stream 'result')
                          'thumbnail'
                        }}"
                        height="31"
                      /></div>
                  {{/if}}
                  <a
                    href="{{fileUrl file.url}}"
                    class="me-2 btn btn-sm btn-outline-{{this.colormodes.inverseMode}}"
                    target="new"
                  >View file
                    <i class="fa-solid fa-up-right-from-square"></i></a>
                  <button
                    {{on
                      "click"
                      (fn
                        this.copyLink
                        (get
                          (get (get file.cloudflare_stream "result") "playback")
                          "hls"
                        )
                        index
                      )
                    }}
                    type="button"
                    class="me-2 btn btn-sm btn-outline-{{this.colormodes.inverseMode}}"
                    target="new"
                  ><span id="copy-{{index}}">Copy link</span>
                    <i class="fa-solid fa-copy"></i></button>

                {{else}}

                  {{#if file.xs.url}}
                    <div class="me-2"><img
                        src="{{fileUrl file.xs.url}}"
                        height="31"
                      /></div>
                  {{/if}}
                  <a
                    href="{{fileUrl file.url}}"
                    class="me-2 btn btn-sm btn-outline-{{this.colormodes.inverseMode}}"
                    target="new"
                  >View file
                    <i class="fa-solid fa-up-right-from-square"></i></a>
                  <button
                    {{on "click" (fn this.copyLink (fileUrl file.url) index)}}
                    type="button"
                    class="me-2 btn btn-sm btn-outline-{{this.colormodes.inverseMode}}"
                    target="new"
                  ><span id="copy-{{index}}">Copy link</span>
                    <i class="fa-solid fa-copy"></i></button>

                {{/if}}

                <span
                  class="me-3 text-danger cursor-pointer"
                  {{on "click" (fn this.deleteFile index)}}
                ><i class="fa-solid fa-circle-xmark"></i></span>
                <span class="text-muted">{{this.explodeFilename
                    file.url
                  }}</span>
              </div>

            {{/if}}
          {{/each}}
        </div>

      </div>
      <div class="form-text text-end">{{if
          @module.input_placeholder
          @module.input_placeholder
          (concat "Enter " @module.input_slug)
        }}</div>
    </div>
  </template>
}
