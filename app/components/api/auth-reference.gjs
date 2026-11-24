import Component from '@glimmer/component';
import hljs from 'highlight.js';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import ENV from 'junction/config/environment';
import { concat } from '@ember/helper';
import { on } from '@ember/modifier';

export default class ApiAuthReference extends Component {
  @service session;
  @service colormodes;
  @service store;

  @tracked apiUrl;
  @tracked copiedUrl = false;
  @tracked copiedWebappUrl = false;
  @tracked copiedJs = false;
  @tracked copiedCurl = false;

  constructor() {
    super(...arguments);
    this.setApiUrl();
  }

  get javascriptSnippet() {
    return `// Using fetch to access your Junction API
const response = await fetch('${this.apiUrl}/api.php/webapp/0', {
  method: 'GET',
  headers: {
    'Content-Type': 'application/vnd.api+json',
    'Authorization': 'Bearer YOUR_API_KEY_HERE'
  }
});
const data = await response.json();
console.log(data);`;
  }

  get curlSnippet() {
    return `curl -X GET \\
  '${this.apiUrl}/api.php/webapp/0' \\
  -H 'Content-Type: application/vnd.api+json' \\
  -H 'Authorization: Bearer YOUR_API_KEY_HERE'`;
  }

  setApiUrl() {
    this.apiUrl = ENV.TribeENV.API_URL;
  }

  @action
  async copyApiWebappUrl() {
    try {
      await navigator.clipboard.writeText(this.apiUrl + '/api.php/webapp/0');
      this.copiedWebappUrl = true;

      // Reset the copied state after 2 seconds
      setTimeout(() => {
        this.copiedWebappUrl = false;
      }, 2000);
    } catch (err) {
      console.error('Failed to copy: ', err);
    }
  }

  @action
  async copyApiUrl() {
    try {
      await navigator.clipboard.writeText(this.apiUrl);
      this.copiedUrl = true;

      // Reset the copied state after 2 seconds
      setTimeout(() => {
        this.copiedUrl = false;
      }, 2000);
    } catch (err) {
      console.error('Failed to copy: ', err);
    }
  }

  @action
  async copyJsSnippet() {
    try {
      await navigator.clipboard.writeText(this.javascriptSnippet);
      this.copiedJs = true;

      setTimeout(() => {
        this.copiedJs = false;
      }, 2000);
    } catch (err) {
      console.error('Failed to copy: ', err);
    }
  }

  @action
  async copyCurlSnippet() {
    try {
      await navigator.clipboard.writeText(this.curlSnippet);
      this.copiedCurl = true;

      setTimeout(() => {
        this.copiedCurl = false;
      }, 2000);
    } catch (err) {
      console.error('Failed to copy: ', err);
    }
  }
  <template>
    <h1 class="text-capitalize text-center mt-5 px-0 display-2 mb-4"><i
        class="fa-solid fa-plug"
      ></i>
      Junction API</h1>

    <ul
      class="nav nav-tabs justify-content-center"
      id="apiAuthReference"
      role="tablist"
    >
      <li class="nav-item" role="presentation">
        <button
          class="nav-link active"
          id="apiAuthReference-javascript-tab"
          data-bs-toggle="tab"
          data-bs-target="#apiAuthReference-javascript-tab-pane"
          type="button"
          role="tab"
          aria-controls="apiAuthReference-javascript-tab-pane"
          aria-selected="true"
        >Javascript</button>
      </li>
      <li class="nav-item" role="presentation">
        <button
          class="nav-link"
          id="apiAuthReference-curl-tab"
          data-bs-toggle="tab"
          data-bs-target="#apiAuthReference-curl-tab-pane"
          type="button"
          role="tab"
          aria-controls="apiAuthReference-curl-tab-pane"
          aria-selected="false"
        >cURL</button>
      </li>
    </ul>

    <div class="text-center my-4 d-none">
      <div class="input-group mx-auto" style="max-width: 600px;">
        <input
          type="text"
          class="form-control"
          value={{concat this.apiUrl "/api.php/webapp/0"}}
          readonly
          aria-label="API URL"
        />
        <button
          class="btn btn-primary"
          type="button"
          {{on "click" this.copyApiWebappUrl}}
        >
          {{#if this.copiedWebappUrl}}
            <i class="fa-solid fa-check"></i>
            Copied!
          {{else}}
            <i class="fa-solid fa-copy"></i>
            Copy Fetch URL
          {{/if}}
        </button>
      </div>
    </div>

    <div class="text-center my-4">
      <div class="input-group mx-auto" style="max-width: 600px;">
        <input
          type="text"
          class="form-control"
          value={{this.apiUrl}}
          readonly
          aria-label="API URL"
        />
        <button
          class="btn btn-primary"
          type="button"
          {{on "click" this.copyApiUrl}}
        >
          {{#if this.copiedUrl}}
            <i class="fa-solid fa-check"></i>
            Copied!
          {{else}}
            <i class="fa-solid fa-copy"></i>
            Copy Tribe URL
          {{/if}}
        </button>
      </div>
    </div>

    <div class="tab-content" id="apiAuthReferenceContent">
      <div
        class="tab-pane fade show active"
        id="apiAuthReference-javascript-tab-pane"
        role="tabpanel"
        aria-labelledby="apiAuthReference-javascript-tab"
        tabindex="0"
      >
        <div
          class="code-container position-relative p-3 border rounded bg-{{this.colormodes.mode}}"
        >
          <button
            class="btn btn-sm btn-primary position-absolute top-0 end-0 m-2"
            type="button"
            {{on "click" this.copyJsSnippet}}
          >
            {{#if this.copiedJs}}
              <i class="fa-solid fa-check"></i>
              Copied!
            {{else}}
              <i class="fa-solid fa-copy"></i>
              Copy
            {{/if}}
          </button>
          <pre class="mb-0"><code
              class="language-javascript"
            >{{this.javascriptSnippet}}</code></pre>
        </div>
      </div>
      <div
        class="tab-pane fade"
        id="apiAuthReference-curl-tab-pane"
        role="tabpanel"
        aria-labelledby="apiAuthReference-curl-tab"
        tabindex="0"
      >
        <div
          class="code-container position-relative p-3 border rounded bg-{{this.colormodes.mode}}"
        >
          <button
            class="btn btn-sm btn-primary position-absolute top-0 end-0 m-2"
            type="button"
            {{on "click" this.copyCurlSnippet}}
          >
            {{#if this.copiedCurl}}
              <i class="fa-solid fa-check"></i>
              Copied!
            {{else}}
              <i class="fa-solid fa-copy"></i>
              Copy
            {{/if}}
          </button>
          <pre class="mb-0"><code
              class="language-bash"
            >{{this.curlSnippet}}</code></pre>
        </div>
      </div>
    </div>
  </template>
}
