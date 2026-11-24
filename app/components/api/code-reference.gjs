import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';

export default class ApiCodeReference extends Component {
  @service type;
  @service colormodes;

  @tracked copiedJs = false;
  @tracked copiedCurl = false;
  @tracked copiedUrl = false;

  @action
  async copyApiUrl() {
    try {
      await navigator.clipboard.writeText(this.type.apiUrl);
      this.copiedUrl = true;

      // Reset the copied state after 2 seconds
      setTimeout(() => {
        this.copiedUrl = false;
      }, 2000);
    } catch (err) {
      console.error('Failed to copy: ', err);
    }
  }

  get javascriptSnippet() {
    return `
// Example of fetching data from your Junction API
const fetchJunctionData = async () => {
  const response = await fetch('${this.type.apiUrl}', {
    method: 'GET',
    headers: {
      'Content-Type': 'application/vnd.api+json'
    }
  });
  
  if (!response.ok) {
    throw new Error('Network response was not ok');
  }
  
  return await response.json();
};

// Example of creating data in your Junction API
const createJunctionData = async (data) => {
  const response = await fetch('${this.type.apiUrl}', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/vnd.api+json',
      'Authorization': 'Bearer YOUR_API_KEY_HERE'
    },
    body: JSON.stringify({
      data: {
        type: '${this.type.slug}',
        attributes: {
          modules: {
            title: data.title,
            content_privacy: data.privacy || 'public',
            // Add other attributes as needed
            type: '${this.type.slug}'
          }
        }
      }
    })
  });
  
  if (!response.ok) {
    throw new Error('Failed to create data');
  }
  
  return await response.json();
};

// GET usage example
try {
  const data = await fetchJunctionData();
  console.log('Junction data:', data);
} catch (error) {
  console.error('Error fetching junction data:', error);
}

// POST usage example
try {
  const newData = await createJunctionData({
    title: 'New ${this.type.title}',
    privacy: 'public'
  });
  console.log('Created new data:', newData);
} catch (error) {
  console.error('Error creating data:', error);
}`;
  }

  get curlSnippet() {
    return `
# Basic GET request to fetch ${this.type.title} data
curl -X GET \\
  '${this.type.apiUrl}' \\
  -H 'Content-Type: application/vnd.api+json'

# POST request to create ${this.type.title} with authorization
curl -X POST \\
  '${this.type.apiUrl}' \\
  -H 'Content-Type: application/vnd.api+json' \\
  -H 'Authorization: Bearer YOUR_API_KEY_HERE' \\
  -d '{
    "data": {
      "type": "${this.type.slug}",
      "attributes": {
        "modules": {
          "title": "New ${this.type.title}",
          "content_privacy": "public",
          "type": "${this.type.slug}"
        }
      }
    }
  }'`;
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
    <ul
      class="nav nav-tabs justify-content-center"
      id="apiCodeReference"
      role="tablist"
    >
      <li class="nav-item" role="presentation">
        <button
          class="nav-link active"
          id="apiCodeReference-javascript-tab"
          data-bs-toggle="tab"
          data-bs-target="#apiCodeReference-javascript-tab-pane"
          type="button"
          role="tab"
          aria-controls="apiCodeReference-javascript-tab-pane"
          aria-selected="true"
        >Javascript</button>
      </li>
      <li class="nav-item" role="presentation">
        <button
          class="nav-link"
          id="apiCodeReference-curl-tab"
          data-bs-toggle="tab"
          data-bs-target="#apiCodeReference-curl-tab-pane"
          type="button"
          role="tab"
          aria-controls="apiCodeReference-curl-tab-pane"
          aria-selected="false"
        >cURL</button>
      </li>
    </ul>

    <div class="text-center my-4">
      <div class="input-group mx-auto" style="max-width: 600px;">
        <input
          type="text"
          class="form-control"
          value={{this.type.apiUrl}}
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
            Copy Track API URL
          {{/if}}
        </button>
      </div>
    </div>

    <div class="tab-content" id="apiCodeReferenceContent">
      <div
        class="tab-pane fade show active"
        id="apiCodeReference-javascript-tab-pane"
        role="tabpanel"
        aria-labelledby="apiCodeReference-javascript-tab"
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
        id="apiCodeReference-curl-tab-pane"
        role="tabpanel"
        aria-labelledby="apiCodeReference-curl-tab"
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
