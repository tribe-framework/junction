#!/usr/bin/env bash

mv .env .env.old
rm package-lock.json
npm run build

if [ ! -f "dist/index.html" ]; then
    echo "~~~~~~~~~~"
    echo -e "\033[31mRun \"npm run build\" before syncing with PHP.\033[0m"
    echo "~~~~~~~~~~"
    exit 1
fi

node php-dist > /dev/null || exit 1

html_content=$(cat dist/index.php)
html_content=$(echo "$html_content" | sed 's|<?php include_once("_head.php");?>|&<title></title>|g')
echo "$html_content" > dist/index.php

echo "~~~~~~~~~~"
echo -e "\033[32mMiddleware successfully installed. Synced \"/dist\" folder with PHP.\033[0m"
echo "~~~~~~~~~~"

exit 0