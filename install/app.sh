#!/bin/bash

# Define paths
SOURCE_DIR="./applications/junction/app"
TEMP_DIR="./temp_app"
DEST_DIR="../ember-junction/blueprints/ember-junction/files/app"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# Create a temporary copy of the app directory
echo "Creating temporary copy of app directory..."
cp -r "$SOURCE_DIR" "$TEMP_DIR"

# Perform replacements on the copy
echo "Performing text replacements..."

# Using sed to make replacements
# -i for in-place editing
# Different syntax for macOS and Linux compatibility
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS version
    find "$TEMP_DIR" -type f -exec sed -i '' \
        -e 's/<title>Junction<\/title>/<title><%= classifiedPackageName %><\/title>/g' \
        -e 's/from '\''junction\/config\/environment'\''/from '\''<%= dasherizedPackageName %>\/config\/environment'\''/g' \
        -e 's/assets\/junction\./assets\/<%= dasherizedPackageName %>./g' \
        -e 's/{{page-title "Junction"}}/{{page-title "<%= classifiedPackageName %>"}}/g' \
        {} +
else
    # Linux version
    find "$TEMP_DIR" -type f -exec sed -i \
        -e 's/<title>Junction<\/title>/<title><%= classifiedPackageName %><\/title>/g' \
        -e 's/from '\''junction\/config\/environment'\''/from '\''<%= dasherizedPackageName %>\/config\/environment'\''/g' \
        -e 's/assets\/junction\./assets\/<%= dasherizedPackageName %>./g' \
        -e 's/{{page-title "Junction"}}/{{page-title "<%= classifiedPackageName %>"}}/g' \
        {} +
fi

# Remove destination directory if it exists
if [ -d "$DEST_DIR" ]; then
    echo "Removing existing destination directory..."
    rm -rf "$DEST_DIR"
fi

# Create destination directory structure
echo "Creating destination directory..."
mkdir -p "$(dirname "$DEST_DIR")"

# Move the modified temporary directory to destination
echo "Moving modified app directory to destination..."
mv "$TEMP_DIR" "$DEST_DIR"

echo "Operation completed successfully!"