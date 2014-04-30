
$       = require 'cheerio'
request = require 'request'

module.exports = (path, callback)->
  headers =
    "User-Agent": "mozdownload-js (http://mozdownload.herokuapp.com/)"
  request.get uri: path, headers: headers, (err, response, body)->

    if response.statusCode != 200
      console.log response.statusCode
      error = Error "Path not found"
      error.statusCode = response.statusCode
      callback error
      return

    try
      parsedHTML = $.load body
    catch parseError
      callback Error "Unable to parse HTML " + parseError.message

    links = []

    parsedHTML('a').map (i, foo)->
      foo = $ foo
      links.push foo.attr 'href'

    callback null, links
