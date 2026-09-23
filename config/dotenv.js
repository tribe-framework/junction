/* eslint-env node */

'use strict';

const path = require('path');

module.exports = function (/* env */) {
  return {
    clientAllowedKeys: [
      'JUNCTION_PASSWORD',
      'JUNCTION_SLUG',
      'PLAUSIBLE_EMBED_URL',
      'HIDE_TRIBE_ATTRIBUTION',
    ],
    fastbootAllowedKeys: [],
    failOnMissingKey: false,
    path: path.join(path.dirname(__dirname), '.env'),
  };
};
