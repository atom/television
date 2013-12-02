{camelize} = require 'underscore.string'
Binding = require '../binding'

module.exports =
class FocusBinding extends Binding
  @id: 'focus'

  @writable: true

  handlingFocus: false
  handlingBlur: false

  constructor: ({@element, @reader, @writer}) ->
    @subscribe @reader, 'value', (value) =>
      if value
        unless @handlingFocus
          @handlingFocus = true
          @element.focus()
          @handlingFocus = false
      else
        unless @handlingBlur
          @handlingBlur = true
          @element.blur()
          @handlingBlur = false

    @element.addEventListener('focus', @onElementFocused)
    @element.addEventListener('blur', @onElementBlurred)

  onElementFocused: =>
    unless @handlingFocus
      @handlingFocus = true
      @writer.emit 'value', true
      @handlingFocus = false

  onElementBlurred: =>
    unless @handlingBlur
      @handlingBlur = true
      @writer.emit 'value', false
      @handlingBlur = false
