import Component from '@glimmer/component';
import { action } from '@ember/object';
import { service } from '@ember/service';
import { tracked } from '@glimmer/tracking';

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
}
