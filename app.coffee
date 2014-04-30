express = require 'express'

scraper = require './lib/scraper'

app = express()

hasKeys = (obj, keys...)->
  keys.every (key)->
    obj.hasOwnProperty key

app.get '', (req, res, next)->

  unless hasKeys req.query, 'type', 'platform', 'locale', 'version'
    res.send "Welcome to mozdownload.herokuapp.com"
    return


  version = req.query.version == 'beta' && 'latest-beta' || req.query.version
  scraper req.query.type, req.query.platform, "firefox", req.query.locale, version, req.query.stub == 'true', (err, result)->
    if err
      next err
    else
      res.send result

server = app.listen process.env.PORT, ->
  console.log 'Listening on port %d', server.address().port
