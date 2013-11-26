{jsdom} = require 'jsdom'
{readFileSync} = require 'fs'

beforeEach ->
  global.window = jsdom().parentWindow
