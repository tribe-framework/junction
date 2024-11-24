# flame-junction-src

Use this repository to make changes to ember-junction blueprint. Always build new Junction for making changes. After making changes, follow steps to publish ember-junction blueprint to npmjs.com

## Steps to publish ember-junction blueprint

```
chmod +x ./install/app.sh; bash ./install/app.sh;
```

```
chmod +x ./install/publish.sh; bash ./install/publish.sh;
```

## To re-build latest Junction

```
wget https://raw.githubusercontent.com/tribe-framework/flame-junction-src/master/install/build.sh; chmod +x build.sh; bash ./build.sh;
```

- Then fill in the .env file with Tribe credentials and run:

```
php sync-types.php
```

## Validate

- Test and validate the changes by using instructions in "Build New Junction".
- Make sure, after testing,
