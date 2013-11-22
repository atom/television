Binding = require '../binding'

module.exports =
class ComponentBinding extends Binding
  @type: 'component'

  constructor: ({@factory, @element, @model, @propertyName}) ->
    @placeholderElement = @element

    @subscribe @model["$#{@propertyName}"], 'value', (model) =>
      if model? and view = @factory.viewForModel(model)
        @element.parentNode.replaceChild(view.element, @element)
        @element = view.element
      else
        @element.parentNode.replaceChild(@placeholderElement, @element)
        @element = @placeholderElement
