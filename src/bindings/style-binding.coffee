{camelize} = require 'underscore.string'
Binding = require '../binding'

module.exports =
class StyleBinding extends Binding
  @id: /style-(.+)/

  constructor: ({id, @element, @reader}) ->
    @stylePropertyName = camelize(id.match(@constructor.id)[1])
    @placeholderValue = @element.style[@stylePropertyName]

    @subscribe @reader, 'value', (value) =>
      if value?
        value += 'px' if typeof value is 'number'
        @element.style[@stylePropertyName] = value
      else
        @element.style[@stylePropertyName] = @placeholderValue
