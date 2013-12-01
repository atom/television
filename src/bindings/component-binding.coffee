Binding = require '../binding'

module.exports =
class ComponentBinding extends Binding
  @id: 'component'

  constructor: ({@factory, @view, @element, @reader}) ->
    @placeholderElement = @element

    @subscribe @reader, 'value', (model) =>
      if @componentView?
        @view.removeChildView(@componentView)
        @componentView = null

      if model? and componentView = @factory.buildView(model)
        @element.parentNode.replaceChild(componentView.element, @element)
        @element = componentView.element
        @view.addChildView(componentView)
        @componentView = componentView
      else
        @element.parentNode.replaceChild(@placeholderElement, @element)
        @element = @placeholderElement
