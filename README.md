[![Build Docker image](https://github.com/tribe-framework/junction/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/tribe-framework/junction/actions/workflows/docker-publish.yml)

# flame-junction-src

Use this repository to make changes to ember-junction blueprint. Always build new Junction for making changes. After making changes, follow steps to publish ember-junction blueprint to npmjs.com

## Steps to publish Docker package

1. The following code inside /applications/junction:

```
rm .env; ember build -prod; php sync-dist.php;
```

## To re-build latest ember and ember-tribe packages

```
wget https://raw.githubusercontent.com/tribe-framework/flame-junction-src/master/install/build.sh; chmod +x build.sh; bash ./build.sh;
```

- Then fill in the .env file with Tribe credentials.

## Validate

- Test and validate the changes by using instructions in "To re-build latest Junction".
- Make sure, after testing,
