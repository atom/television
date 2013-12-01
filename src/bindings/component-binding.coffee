Binding = require '../binding'

module.exports =
class ComponentBinding extends Binding
  @id: 'component'

  constructor: ({@factory, @element, @reader}) ->
    @placeholderElement = @element

    @subscribe @reader, 'value', (model) =>
      if model? and view = @factory.buildView(model)
        @element.parentNode.replaceChild(view.element, @element)
        @element = view.element
      else
        @element.parentNode.replaceChild(@placeholderElement, @element)
        @element = @placeholderElement
