express = require 'express'

scraper = require './lib/scraper'

app = express()

hasKeys = (obj, keys...)->
  keys.every (key)->
    obj.hasOwnProperty key

scrapeIt = (params, action, res, next)->
  channel = params.channel == 'beta' && 'latest-beta' || params.channel
  scraper params.type, params.platform, "firefox", params.locale, channel, params.stub, (err, result)->
    if err
      next err
    else if action == 'redirect'
      res.redirect result.url
    else if action == 'version'
      res.send result.version
    else
      res.send result

app.get '/firefox/:locale/:platform/:type/:channel', (req, res, next)->
  req.params.stub = req.query.stub == 'true'
  scrapeIt req.params, "json", res, next

app.get '/firefox/:locale/:platform/:type/:channel/:action', (req, res, next)->
  req.params.stub = req.query.stub == 'true'
  scrapeIt req.params,  req.params.action, res, next

app.get '', (req, res, next)->
  if hasKeys req.query, 'type', 'platform', 'locale', 'version'
    req.query.stub = req.query.stub == 'true'
    req.query.channel = req.query.version
    scrapeIt req.query, req.query.do, res, next

  else
    res.send "Welcome to mozdownload.tokbox.com."
    return

server = app.listen process.env.PORT, ->
  console.log 'Listening on port %d', server.address().port
