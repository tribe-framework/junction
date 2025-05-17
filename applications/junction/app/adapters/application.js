import JSONAPIAdapter from '@ember-data/adapter/json-api';
import ENV from 'junction/config/environment';
import { underscore } from '@ember/string';

export default class ApplicationAdapter extends JSONAPIAdapter {
  host = ENV.TribeENV.API_URL;
  namespace = 'api.php';

  get headers() {
    let headers = {};

    // API key here will show up as HTTP_X_API_KEY in PHP
    if (ENV.TribeENV.API_KEY) {
      headers['X-API-KEY'] = `Bearer ${ENV.TribeENV.API_KEY}`;
    } else {
      headers['X-API-KEY'] = `Bearer junction`;
    }

    return headers;
  }

  pathForType(type) {
    return underscore(type);
  }
}
