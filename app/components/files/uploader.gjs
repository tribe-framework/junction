import Component from '@glimmer/component';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import { service } from '@ember/service';
import { Queue } from 'ember-file-upload';
import ENV from 'junction/config/environment';
import { later } from '@ember/runloop';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';
import fileQueue from 'ember-file-upload/helpers/file-queue';
import FileDropzone from 'ember-file-upload/components/file-dropzone';

export default class FilesUploaderComponent extends Component {
  @service fileQueue;
  @service store;
  @service colormodes;
  @service type;

  explodeFilename = (filename) => {
    var base = new String(filename).substring(filename.lastIndexOf('/') + 1);
    if (base.lastIndexOf('.') != -1)
      base = base.substring(0, base.lastIndexOf('.'));
    return base;
  };

  get queue() {
    return this.fileQueue.findOrCreate('main-files-uploader');
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

          if (this.args.updateOnUpload !== undefined)
            this.args.updateOnUpload(data.file);
          else this.type.changeType(this.type.currentType);
        } else if (data.status == 'error') {
          alert(data.error_message);
        }
      });
    } catch (error) {
      file.state = 'aborted';
    }
  }
  <template>
    <div class="row mt-3 row-cols-1 g-3 mx-0">
      <div class="card px-0 mx-0 border-0">

        <div
          class="card-body p-0"
          {{on "click" (fn this.triggerSelectFile "main-files-uploader")}}
        >

          {{#let
            (fileQueue name="main-files-uploader" onFileAdded=this.uploadFile)
            as |queue|
          }}
            <div class="d-none">
              <input
                class="form-control"
                type="file"
                id="main-files-uploader"
                {{queue.selectFile}}
              />
            </div>
            <FileDropzone @queue={{queue}} as |dropzone|>
              {{#if dropzone.active}}
                <div
                  class="text-center text-{{this.colormodes.inverseMode}}
                    w-100 fs-4 p-5"
                  style="border: 2px dashed #000;"
                ><i
                    class="fa-solid fa-wand-magic-sparkles fa-spin"
                  ></i>&nbsp;&nbsp;Drop to upload</div>
              {{else if queue.files.length}}
                <div
                  class="text-center text-{{this.colormodes.inverseMode}}
                    w-100 fs-4 p-5"
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
                  class="text-center text-muted w-100 fs-4 p-5"
                  style="border: 2px dashed #eee;"
                ><i class="fa-solid fa-cloud-arrow-up"></i>&nbsp;&nbsp;{{if
                    @placeholder
                    @placeholder
                    "Drag and drop files here to upload them"
                  }}</div>
              {{/if}}
            </FileDropzone>
          {{/let}}

        </div>

      </div>
    </div>
  </template>
}
