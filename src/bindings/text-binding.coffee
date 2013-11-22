Binding = require '../binding'

module.exports =
class TextBinding extends Binding
  @type: 'text'

  constructor: ({@element, @model, @propertyName}) ->
    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      @element.textContent = value
