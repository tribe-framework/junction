#!/usr/bin/env bash

mv .env .env.old
rm package-lock.json
npm run build || exit 1
node php-dist || exit 1
sed 's|<?php include_once("_head.php");?>|&<title></title>|' dist/index.php > dist/index.php.tmp && mv dist/index.php.tmp dist/index.php
rm -f dist.zip
(cd dist && zip -qr ../dist.zip .) || exit 1