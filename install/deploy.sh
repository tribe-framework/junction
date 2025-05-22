#!/usr/bin/env bash

cd applications/junction

# remove .env file
rm .env

# build for production
npm run build

# run php script to sync dist
php sync-dist.php

exit 0
