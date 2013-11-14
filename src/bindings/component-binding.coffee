Binding = require './binding'

module.exports =
class ComponentBinding extends Binding
  constructor: (@template, @element, @model, @propertyName) ->
    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      component = @template.visualize(value)
      @element.parentNode.replaceChild(component, @element)
      @element = component
