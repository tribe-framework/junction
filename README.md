# flame-junction-src

Use this repository to make changes to ember-junction blueprint. Always build new Junction for making changes. After making changes, follow steps to publish ember-junction blueprint to npmjs.com

## Build New Junction

```
wget https://raw.githubusercontent.com/tribe-framework/flame-junction-src/master/install/build.sh; chmod +x build.sh; bash ./build.sh;
```

Then fill in the .env file with Tribe credentials and run:

```
php sync-types.php
```

## Steps to publish ember-junction blueprint

After installation make a copy of the "app" folder outside the project and:

- Replace "<title>Junction</title>" with "<title><%= classifiedPackageName %></title>"
- Replace "from 'junction/config/environment'" with "from '<%= dasherizedPackageName %>/config/environment'"
- Replace "assets/junction." with "assets/<%= dasherizedPackageName %>."
- Replace "{{page-title "Junction"}}" with "{{page-title "<%= classifiedPackageName %>"}}"
- Move this new "app" folder to ember-junction/blueprints/ember-junction/files/app
- "npm publish" in ember-junction

## Validate

- Test and validate the changes by using instructions in "Build New Junction".
- Make sure, after testing, version number matches with flame-junction-dist repo.
