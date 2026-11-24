import { useLegacyStore } from '@warp-drive/legacy';
import { JSONAPICache } from '@warp-drive/json-api';
import { dasherize } from '@ember/string';

const LegacyStore = useLegacyStore({
  linksMode: false,
  legacyRequests: true,
  cache: JSONAPICache,
  handlers: [],
  schemas: [],
});

const typed = (type) => (typeof type === 'string' ? dasherize(type) : type);

export default class Store extends LegacyStore {
  findRecord(type, ...rest) {
    return super.findRecord(typed(type), ...rest);
  }

  findAll(type, ...rest) {
    return super.findAll(typed(type), ...rest);
  }

  query(type, ...rest) {
    return super.query(typed(type), ...rest);
  }

  queryRecord(type, ...rest) {
    return super.queryRecord(typed(type), ...rest);
  }

  peekRecord(type, ...rest) {
    return super.peekRecord(typed(type), ...rest);
  }

  peekAll(type, ...rest) {
    return super.peekAll(typed(type), ...rest);
  }

  createRecord(type, ...rest) {
    return super.createRecord(typed(type), ...rest);
  }

  unloadAll(type, ...rest) {
    return super.unloadAll(typed(type), ...rest);
  }
}
