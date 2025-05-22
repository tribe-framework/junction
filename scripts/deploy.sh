#!/usr/bin/env bash

cd applications/junction

# create backup of .env then remove it
[[ -f .env ]] && cp .env ../.junction.env
rm .env

# build for production
npm run build

# run php script to sync dist
php sync-dist.php

ln -sf ../.junction.env .env

exit 0
