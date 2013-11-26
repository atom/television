{jsdom} = require 'jsdom'
{readFileSync} = require 'fs'

beforeEach ->
  browser = jsdom()
  global.window = browser.parentWindow
  global.document = window.document

  activeElement = document.body
  Object.defineProperty document, 'activeElement',
    get: -> activeElement
    set: (newActiveElement) ->
      blurEvent = document.createEvent("HTMLEvents")
      blurEvent.initEvent("blur", false, false)
      focusEvent = document.createEvent("HTMLEvents")
      focusEvent.initEvent("focus", false, false)
      oldActiveElement = activeElement
      activeElement = newActiveElement
      oldActiveElement.dispatchEvent(blurEvent)
      newActiveElement.dispatchEvent(focusEvent)
