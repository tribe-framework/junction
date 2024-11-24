#!/bin/bash

##################
##################

# increment version of flame-junction-src

##################
##################

# Function to get the latest version tag
get_latest_version() {
    git fetch --tags > /dev/null 2>&1
    latest_tag=$(git describe --tags `git rev-list --tags --max-count=1` 2>/dev/null)
    
    if [ -z "$latest_tag" ]; then
        echo "0.0.0"
    else
        echo "$latest_tag"
    fi
}

# Function to increment version
increment_version() {
    local version=$1
    local major minor patch
    
    # Split version into major.minor.patch
    IFS='.' read -r major minor patch <<< "$version"
    
    # Convert to integers
    patch=$((10#$patch))
    minor=$((10#$minor))
    major=$((10#$major))
    
    # Increment patch, if patch reaches 24, increment minor and reset patch
    if [ $patch -ge 24 ]; then
        minor=$((minor + 1))
        patch=0
    else
        patch=$((patch + 1))
    fi
    
    echo "$major.$minor.$patch"
}

# Main execution

# Check if we're on master branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "master" ]; then
    echo "Error: Not on master branch"
    exit 1
fi

# Get the latest version
current_version=$(get_latest_version)
echo "Current version: $current_version"

# Calculate new version
new_version=$(increment_version "$current_version")
echo "New version: $new_version"

# Create and push new tag
echo "Creating new tag v$new_version..."
git tag -a "v$new_version" -m "Version $new_version"

echo "Pushing new tag to origin..."
git push origin "v$new_version"

echo "Version update complete!"

##################
##################

# ember-junction npm publish

##################
##################

# Change to the ember-junction directory
cd ../ember-junction || {
    echo "Error: Could not change to ember-junction directory"
    exit 1
}

# Function to increment version based on patch number
increment_version() {
    local version=$1
    local major=$(echo $version | cut -d. -f1)
    local minor=$(echo $version | cut -d. -f2)
    local patch=$(echo $version | cut -d. -f3)
    
    # If patch is 24, increment minor and reset patch to 0
    if [ "$patch" -eq 24 ]; then
        minor=$((minor + 1))
        patch=0
    else
        # Otherwise just increment patch
        patch=$((patch + 1))
    fi
    
    echo "$major.$minor.$patch"
}

# Check if there are any uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: There are uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Read current version from package.json
current_version=$(node -p "require('./package.json').version")

if [ -z "$current_version" ]; then
    echo "Error: Could not read version from package.json"
    exit 1
fi

# Calculate new version
new_version=$(increment_version "$current_version")

echo "Current version: $current_version"
echo "New version: $new_version"

# Update package.json with new version
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS version
    sed -i '' "s/\"version\": \"$current_version\"/\"version\": \"$new_version\"/" package.json
else
    # Linux version
    sed -i "s/\"version\": \"$current_version\"/\"version\": \"$new_version\"/" package.json
fi

# Verify the change
updated_version=$(node -p "require('./package.json').version")
if [ "$updated_version" != "$new_version" ]; then
    echo "Error: Version update failed"
    exit 1
fi

# Git operations
echo "Committing version update..."
git add package.json
git commit -m "Bump version to ${new_version}"

# Create a new git tag
echo "Creating git tag v${new_version}..."
git tag -a "v${new_version}" -m "Version ${new_version}"

# Push changes and tags to origin/master
echo "Pushing to origin/master..."
git push origin master
git push origin "v${new_version}"

if [ $? -ne 0 ]; then
    echo "Error: Failed to push to git repository"
    exit 1
fi

# Publish to npm
echo "Publishing to npm..."
npm publish

if [ $? -eq 0 ]; then
    echo "Successfully published version $new_version to npm"
    echo "Git tag v${new_version} has been created and pushed"
else
    echo "Error: npm publish failed"
    # Cleanup if npm publish fails
    echo "Rolling back git changes..."
    git tag -d "v${new_version}"
    git push origin :"v${new_version}"
    git reset --hard HEAD~1
    git push origin master --force
    exit 1
fi