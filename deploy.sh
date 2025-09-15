#!/usr/bin/env bash

mv .env .env.old
npm run build
php sync-dist.php

exit 0