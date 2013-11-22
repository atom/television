{camelize} = require 'underscore.string'
Binding = require '../binding'

module.exports =
class AttributeBinding extends Binding
  @type: /style-(.+)/

  constructor: ({type, @element, @model, @propertyName}) ->
    @stylePropertyName = camelize(type.match(@constructor.type)[1])
    @placeholderValue = @element.style[@stylePropertyName]
    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      value ?= @placeholderValue
      @element.style[@stylePropertyName] = value