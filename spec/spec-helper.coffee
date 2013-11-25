{jsdom} = require 'jsdom'
{readFileSync} = require 'fs'
PEG = require 'pegjs'

require.extensions['.pegjs'] = (module) ->
  module.exports = PEG.buildParser(readFileSync(module.filename, 'utf8'))

beforeEach ->
  global.window = jsdom().parentWindow
