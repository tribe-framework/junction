#!/usr/bin/env bash

mv .env .env.old
npm run build

# Check if dist/index.html exists
if [ ! -f "dist/index.html" ]; then
    echo "~~~~~~~~~~"
    echo -e "\033[31mRun \"npm run build\" before syncing with PHP.\033[0m"
    echo "~~~~~~~~~~"
    exit 1
fi

# Read the HTML content
html_content=$(cat dist/index.html)

# Replace head, before title
html_content=$(echo "$html_content" | sed 's|<title>|<?php include_once("_head.php");?><title>|g')

# Replace head-footer, before </head> ends
html_content=$(echo "$html_content" | sed 's|</head>|<?php include_once("_head_footer.php");?></head>|g')

# Replace body-footer, before </body> ends
html_content=$(echo "$html_content" | sed 's|</body>|<?php include_once("_body_footer.php");?></body>|g')

# Remove meta description tag using sed
# This removes the entire <meta name="description" ...> tag
html_content=$(echo "$html_content" | sed 's|<meta[^>]*name="description"[^>]*>||gi')

# Remove title tag content but keep the structure for PHP includes
# First, remove any existing <title>...</title> content between the PHP includes
html_content=$(echo "$html_content" | sed 's|<title>\([^<]*\)</title>|<title></title>|g')

# Prepend _init.php include at the very beginning
html_content="<?php include_once(\"_init.php\");?>$html_content"

# Write the modified content to index.php
echo "$html_content" > dist/index.php

# Success message
echo "~~~~~~~~~~"
echo -e "\033[32mMiddleware successfully installed. Synced \"/dist\" folder with PHP.\033[0m"
echo "~~~~~~~~~~"

exit 0