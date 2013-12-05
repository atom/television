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

  destroy: ->
    super
    @element.removeEventListener('focus', @onElementFocused)
    @element.removeEventListener('blur', @onElementBlurred)

  focusElement: ->
    return if @handlingFocus
    return if document.activeElement is @element
    @handlingFocus = true
    @element.focus()
    @handlingFocus = false

  blurElement: ->
    return if @handlingBlur
    return unless document.activeElement is @element
    @handlingBlur = true
    @element.blur()
    @handlingBlur = false

  onElementFocused: =>
    return if  @handlingFocus
    @handlingFocus = true
    @writer.emit 'value', true
    @handlingFocus = false

  onElementBlurred: =>
    return if @handlingBlur
    @handlingBlur = true
    @writer.emit 'value', false
    @handlingBlur = false
