# mozdownload

[mozdownload](https://github.com/tokboxnerds/mozdownload) is a [node.js](http://www.nodejs.org/) / [coffeescript](http://coffeescript.org/) server to make it easier to download Firefox without knowing the version number associated with a given channel.

The parser is largely based on [mozilla/mozdownload](https://github.com/mozilla/mozdownload) which is a python CLI tool.

## Running it

1. Push it to [heroku](http://www.heroku.com/)
2. npm install && PORT=8080 node boot.js

## API

### JSON with version & download URL

    http://mozdownload/firefox/{lang}/{platform}/{type}/{channel}

Where:

* **lang** is a language that Mozilla build for (see [latest mac](https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/latest/mac/) for a sample list). Note: for nightly builds typically only en-US will be available.

* **platform** is the OS/architechture. Valid values at time of writing are `linux`, `linux64`, `mac`, and `win32`. `mac64` and `win64` may become available later.

* **type** is `release` or `nightly`

* **channel** will depend on **type**:

  * for `release`, typical values are `latest` (the current stable release) or `beta` (the latest beta). Additionaly other folder names found in the [releases](https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/) may work.

  * for `nightly`, typical values are `trunk` (the latest nightly) or `mozilla-aurora` (the latest aurora). Other folder names (starting with latest in [nightly](https://ftp.mozilla.org/pub/mozilla.org/firefox/nightly) may work.

### Redirect to download URL

    http://mozdownload/firefox/{lang}/{platform}/{type}/{channel}/redirect

Will do a 302 redirect to the download URL


### Redirect to download URL

    http://mozdownload/firefox/{lang}/{platform}/{type}/{channel}/version

The body will simply be the version string (not enclosed in JSON).

## Improvements

You could improve this app by taking advantage of [libs/product-details](http://svn.mozilla.org/libs/product-details/json/firefox_versions.json) which could reducing the scraping required.

Please consider changing the user-agent sent to Mozilla in directory_parser.coffee.
