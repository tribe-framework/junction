'use strict';

const fs = require('fs');
const path = require('path');

module.exports = function (environment) {
  const envFile = path.join(__dirname, '..', '.env');
  if (fs.existsSync(envFile)) {
    process.loadEnvFile(envFile);
  }

  const ENV = {
    modulePrefix: 'junction',
    environment,
    rootURL: '/',
    locationType: 'history',
    EmberENV: {
      EXTEND_PROTOTYPES: false,
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. EMBER_NATIVE_DECORATOR_SUPPORT: true
      },
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    },

    JUNCTION_SLUG: process.env.JUNCTION_SLUG,
    PLAUSIBLE_EMBED_URL: process.env.PLAUSIBLE_EMBED_URL,
    HIDE_TRIBE_ATTRIBUTION: process.env.HIDE_TRIBE_ATTRIBUTION,
  };

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
    ENV.APP.autoboot = false;
  }

  if (environment === 'production') {
    // here you can enable a production-specific feature
  }

  return ENV;
};