Binding = require './binding'

module.exports =
class ComponentBinding extends Binding
  constructor: (@template, @element, @model, @propertyName) ->
    @placeholderElement = @element

    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      if value? and component = @template.visualize(value)
        @element.parentNode.replaceChild(component, @element)
        @element = component
      else
        @element.parentNode.replaceChild(@placeholderElement, @element)
        @element = @placeholderElement
