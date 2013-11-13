Binding = require './binding'

module.exports =
class TextBinding extends Binding
  @type: 'text'

  constructor: (@template, @element, @model, @propertyName) ->
    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      @element.textContent = value
