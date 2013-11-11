{jsdom} = require 'jsdom'

beforeEach ->
  global.window = jsdom().parentWindow
