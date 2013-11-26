{camelize} = require 'underscore.string'
Binding = require '../binding'

module.exports =
class FocusBinding extends Binding
  @id: 'focus'

  @writable: true

  constructor: ({@element, @reader, @writer}) ->
    @subscribe @reader, 'value', (value) =>
      if value
        @element.focus()
      else
        @element.blur()

    @element.addEventListener('focus', @onElementFocused)
    @element.addEventListener('blur', @onElementBlurred)

  onElementFocused: =>
    @writer.emit 'value', true

  onElementBlurred: =>
    @writer.emit 'value', false
