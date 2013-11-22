Binding = require './binding'

module.exports =
class AttributeBinding extends Binding
  @type: /attribute-(.+)/

  constructor: ({type, @element, @model, @propertyName}) ->
    @attributeName = type.match(@constructor.type)[1]
    @placeholderValue = @element.getAttribute(@attributeName)
    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      if value ?= @placeholderValue
        @element.setAttribute(@attributeName, value)
      else
        @element.removeAttribute(@attributeName)
