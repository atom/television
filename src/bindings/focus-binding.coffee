{camelize} = require 'underscore.string'
Binding = require '../binding'

module.exports =
class FocusBinding extends Binding
  @id: 'focus'

  @writable: true

  handlingFocus: false
  handlingBlur: false

  constructor: ({@view, @element, @reader, @writer}) ->
    @subscribe @reader, 'value', (value) =>
      if value
        @focusElement()
      else
        @blurElement()

    @element.addEventListener('focus', @onElementFocused)
    @element.addEventListener('blur', @onElementBlurred)

  focusElement: ->
    unless @handlingFocus
      @handlingFocus = true
      @element.focus()
      @handlingFocus = false

  blurElement: ->
    unless @handlingBlur
      @handlingBlur = true
      @element.blur()
      @handlingBlur = false

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
