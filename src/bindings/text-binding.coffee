Binding = require './binding'

module.exports =
class TextBinding extends Binding
  constructor: ({@element, @model, @propertyName}) ->
    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      @element.textContent = value
