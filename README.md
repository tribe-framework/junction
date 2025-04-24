[![Build Docker image](https://github.com/tribe-framework/junction/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/tribe-framework/junction/actions/workflows/docker-publish.yml)

# flame-junction-src

Use this repository to make changes to ember-junction blueprint. Always build new Junction for making changes. After making changes, follow steps to publish ember-junction blueprint to npmjs.com

## Steps to publish ember-junction blueprint

1. The following code copies changes from ./applications/junction/app to ../ember-junction/blueprints/ember-junction/files/app folder in the (ember-junction repo):

```
chmod +x ./install/app.sh; bash ./install/app.sh;
```

2. Manually commit changes on ember-junction repo.

3. The following code publishes the npm package:

```
chmod +x ./install/publish.sh; bash ./install/publish.sh;
```

## To re-build latest Junction

```
wget https://raw.githubusercontent.com/tribe-framework/flame-junction-src/master/install/build.sh; chmod +x build.sh; bash ./build.sh;
```

- Then fill in the .env file with Tribe credentials.

## Validate

- Test and validate the changes by using instructions in "To re-build latest Junction".
- Make sure, after testing,
