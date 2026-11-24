import Component from '@glimmer/component';
import { service } from '@ember/service';
import { action } from '@ember/object';
import { tracked } from '@glimmer/tracking';
import Papa from 'papaparse';
import { on } from '@ember/modifier';
import { fn } from '@ember/helper';

export default class FilesCsvUploader extends Component {
  @service store;
  @service colormodes;
  @service type;

  @tracked isProcessing = false;
  @tracked processingProgress = 0;
  @tracked processingErrors = [];
  @tracked headers = [];
  @tracked rowCount = 0;

  @action
  triggerSelectFile(e) {
    document.querySelector('#' + e).click();
  }

  @action
  async processFile(file) {
    this.isProcessing = true;
    this.processingProgress = 0;
    this.processingErrors = [];
    this.rowCount = 0;

    try {
      // Read the file as text first
      const reader = new FileReader();

      reader.onload = (event) => {
        const csvText = event.target.result;

        // Now parse the CSV text with PapaParse
        Papa.parse(csvText, {
          header: true,
          skipEmptyLines: true,
          dynamicTyping: true,
          complete: (results) => {
            if (results) {
              this.type.csvData = results.data;
              this.headers = results.meta.fields || [];
              this.rowCount = results.data.length;
              this.processingErrors = results.errors || [];

              if (this.args.onCsvProcessed) {
                this.args.onCsvProcessed({
                  data: this.type.csvData,
                  headers: this.headers,
                  rowCount: this.rowCount,
                  errors: this.processingErrors,
                });
              }
            } else {
              this.processingErrors.push({
                message: 'Failed to process CSV: Results object is undefined',
              });
            }

            this.processingProgress = 100;
            this.isProcessing = false;
          },
          error: (error) => {
            this.processingErrors.push(error);
            this.isProcessing = false;
          },
        });
      };

      reader.onerror = (error) => {
        this.processingErrors.push({
          message: 'Error reading file: ' + error,
        });
        this.isProcessing = false;
      };

      // Start reading the file
      reader.readAsText(file);
    } catch (error) {
      this.processingErrors.push({
        message: 'Exception while processing file: ' + error.message,
      });
      this.isProcessing = false;
    }
  }

  @action
  handleFileSelect(event) {
    const file = event.target.files[0];
    if (file) {
      this.processFile(file);
    }
  }

  @action
  handleFileDrop(event) {
    const files = event.detail;
    if (files && files.length > 0) {
      this.processFile(files[0]);
    }
  }
  <template>
    <div class="row mt-3 row-cols-1 g-3 mx-0">
      <div class="card px-0 mx-0 border-0">
        <div
          class="card-body p-0"
          {{on "click" (fn this.triggerSelectFile "csv-file-uploader")}}
        >
          <div class="d-none">
            <input
              class="form-control"
              type="file"
              id="csv-file-uploader"
              accept=".csv"
              {{on "change" this.handleFileSelect}}
            />
          </div>

          {{#if this.isProcessing}}
            <div
              class="text-center text-{{this.colormodes.inverseMode}}
                w-100 fs-4 p-5"
              style="border: 2px dashed #eee;"
            >
              <i class="fa-solid fa-cog fa-spin"></i>&nbsp;Processing CSV file ({{this.processingProgress}}%
              done)
            </div>
            <div
              class="progress"
              role="progressbar"
              aria-valuenow="{{this.processingProgress}}"
              aria-valuemin="0"
              aria-valuemax="100"
            >
              <div
                class="progress-bar progress-bar-striped progress-bar-animated"
                style="width: {{this.processingProgress}}%"
              ></div>
            </div>
          {{else if this.type.csvData}}
            <div
              class="text-center text-{{this.colormodes.inverseMode}}
                w-100 fs-4 p-3"
              style="border: 2px solid #eee;"
            >
              <div>
                <i class="fa-solid fa-hourglass-start"></i>&nbsp;CSV has been
                read.<br /><span class="text-primary">Would you like to save
                  these records?</span>
              </div>
              <div class="fs-6 mt-2">
                <strong>{{this.rowCount}}</strong>
                records found with
                <strong>{{this.headers.length}}</strong>
                fields
              </div>
              {{#if this.processingErrors.length}}
                <div class="alert alert-warning mt-2 fs-6">
                  <strong>{{this.processingErrors.length}} issues found</strong>
                  <ul class="text-start small">
                    {{#each this.processingErrors as |error|}}
                      <li>{{error.message}}</li>
                    {{/each}}
                  </ul>
                </div>
              {{/if}}
            </div>
          {{else}}
            <div
              class="text-center text-muted w-100 fs-4 p-5"
              style="border: 2px dashed #eee;"
              ondragover="event.preventDefault();"
              ondrop="event.preventDefault(); this.dispatchEvent(new CustomEvent('file-drop', {detail: event.dataTransfer.files}));"
              {{on "file-drop" this.handleFileDrop}}
            >
              <i class="fa-solid fa-file-csv"></i>&nbsp;&nbsp;{{if
                @placeholder
                @placeholder
                "Drag and drop CSV file here or click to select"
              }}
            </div>
          {{/if}}

          {{#if this.type.csvData}}
            <div class="mt-3">
              <button
                type="button"
                class="btn btn-outline-secondary btn-sm me-2"
                {{on "click" (fn (mut this.type.csvData) null)}}
              >
                <i class="fa-solid fa-undo"></i>
                Clear and Upload Different File
              </button>
            </div>
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
