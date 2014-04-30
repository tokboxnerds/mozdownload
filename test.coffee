scaper = require './lib/scraper'

scaper 'nightly', 'win32', 'firefox', 'en-US', 'trunk', false, (err, result)->
  if err
    throw err
  else
    console.log JSON.stringify result
