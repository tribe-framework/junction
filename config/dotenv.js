/* eslint-env node */

'use strict';

const path = require('path');

module.exports = function (/* env */) {
  return {
    clientAllowedKeys: [
      'JUNCTION_PASSWORD',
      'JUNCTION_SLUG',
      'PLAUSIBLE_AUTH',
      'PLAUSIBLE_DOMAIN',
      'HIDE_POSTCODE_ATTRIBUTION',
    ],
    fastbootAllowedKeys: [],
    failOnMissingKey: false,
    path: path.join(path.dirname(__dirname), '.env'),
  };
};
