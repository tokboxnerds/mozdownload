BASE_URL = 'https://ftp.mozilla.org/pub/mozilla.org'

APPLICATIONS = ['b2g', 'firefox', 'thunderbird']

PLATFORM_FRAGMENTS =
  linux:   'linux-i686'
  linux64: 'linux-x86_64'
  mac:     'mac'
  mac64:   'mac64'
  win32:   'win32'
  win64:   'win64-x86_64'

DEFAULT_FILE_EXTENSIONS =
  linux:   'tar.bz2'
  linux64: 'tar.bz2'
  mac:     'dmg'
  mac64:   'dmg'
  win32:   'exe'
  win64:   'exe'

path    = require 'path'
S       = require 'string'
url     = require 'url'

directoryParser = require './directory_parser'

urljoin = (a, b)->
  pre = url.parse a
  pre.pathname = path.join pre.pathname, b
  pre.format()

class Scraper
  
  constructor: (@platform, @application, @locale, @version = 'latest', @isStubInstaller, extension, base_url=BASE_URL)->
    @base_url = urljoin base_url, @application
    @extension = extension or DEFAULT_FILE_EXTENSIONS[@platform]

  getDownloadURL: (callback)->
    @finalUrl (err, downloadUrl)=>
      if err
        callback err
      else
        callback null,
          href: downloadUrl
          version: @extractVersion path.basename downloadUrl

  extractVersion: (fromString, full)->
    regex = new RegExp "^#{ @application }-(.*)\.#{ @locale }", 'i'
    if version = fromString.match(regex)?[1]
      if full
        version.match(/([0-9]+)\.([0-9]+)([a-z]?)([0-9]*)/)
      else
        version

  getBinary: (callback)->
    if @_binary?
      callback null, @_binary
      return
    directoryParser @path(), (err, entries)=>
      if err
        callback err
      else unless entries?
        callback Error 'Unexpected response from directoryParser'
      else if entries.length == 0
        callback Error 'No entries found'
      else
        if (@_binary = @pickEntry(entries))?
          callback null, @_binary
        else
          callback Error 'No matching binary found'

  pickEntry: (entries)->
    pattern = new RegExp @binaryRegex(), 'i'
    binary = null
    for entry in entries
      if binary = entry.match(pattern)?[0]
        break
    binary
     
  path: ->
    urljoin @base_url, @pathComponent()

  finalUrl: (callback)->
    @getBinary (err, binary)=>
      if err
        callback err
      else
        callback null, urljoin @path(), binary

class ReleaseScraper extends Scraper

  binaryRegex: ->
    releasePaths =
      linux:    '^{{application}}-.*\.{{extension}}$'
      linux64:  '^{{application}}-.*\.{{extension}}$'
      mac:      '^{{application}}.*\.{{extension}}$'
      mac64:    '^{{application}}.*\.{{extension}}$'
      win32:    '^{{application}}.*{{stub}}.*\.{{extension}}$'
      win64:    '^{{application}}.*{{stub}}.*\.{{extension}}$'

    S(releasePaths[@platform]).template(
      application: @application
      extension: @extension
      stub: @isStubInstaller && 'Stub' || ''
    ).s

  pathComponent: ->
    "releases/#{@version}/#{@platform}/#{@locale}"

class NightlyScraper extends Scraper

  binaryRegex: ->
    base = '^{{application}}-.*\.{{locale}}\.{{platform}}'
    suffix =
      linux: '\.{{extension}}$'
      linux64: '\.{{extension}}$'
      mac: '\.{{extension}}$'
      mac64: '\.{{extension}}$'
      win32: '(\.installer{{stub}})?\.{{extension}}$'
      win64: '(\.installer{{stub}})?\.{{extension}}$'

    S(base + suffix[@platform]).template(
      application: @application
      extension: @extension
      stub: @isStubInstaller && '-stub' || ''
      locale: @locale
      platform: PLATFORM_FRAGMENTS[@platform]
    ).s

  pathComponent: ->
    "nightly/latest-#{@version}"

  pickEntry: (entries)->
    pattern = new RegExp @binaryRegex(), 'i'
    binary = null
    entries = entries.reduce (collect, entry)->
      if binary = entry.match(pattern)?[0]
        collect.push binary
      collect
    , []

    if entries.length == 0
      entries[0]
    else
      entries = entries.sort (a, b)=>
        a = @extractVersion a, true
        b = @extractVersion b, true
        a[0] = parseInt a[0], 10
        b[0] = parseInt b[0], 10
        a[1] = parseInt a[1], 10
        b[1] = parseInt b[1], 10

        if a[0] < b[0]
          -1

        else if a[0] > b[0]
          1

        # neither have qualifier
        else if a[2] == b[2] == ''
          0

        # a has no qualifier
        else if a[2] == ''
          1

        # b has no qualifier
        else if b[2] == ''
          -1

        else
          a[3] = a[3] == '' && parseInt a[3], 10
          b[3] = b[3] == '' && parseInt b[3], 10

          if a[2] < b[2]
            -1

          else if a[2] > b[2]
            1

          else if a[3] < b[3]
            -1

          else if a[3] > b[3]
            1

          else
            0

      entries[entries.length - 1]

BUILD_TYPES =
  release: ReleaseScraper
  nightly: NightlyScraper

module.exports = (type, platform, application, locale, version, isStubInstaller, callback)->
  unless BUILD_TYPES[type]?
    callback new Error 'Unsupported build type'
    return

  BuilderClass = BUILD_TYPES[type]
  builder = new BuilderClass platform, application, locale, version, isStubInstaller

  builder.getDownloadURL callback
