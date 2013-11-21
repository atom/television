Binding = require './binding'

module.exports =
class ComponentBinding extends Binding
  constructor: (@template, @element, @model, @propertyName) ->
    @placeholderElement = @element

    @subscribe @model["$#{@propertyName}"], 'value', (model) =>
      if model? and view = @template.viewForModel(model)
        @element.parentNode.replaceChild(view.element, @element)
        @element = view.element
      else
        @element.parentNode.replaceChild(@placeholderElement, @element)
        @element = @placeholderElement
