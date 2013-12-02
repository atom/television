Binding = require '../binding'

module.exports =
class ComponentBinding extends Binding
  @id: 'component'

  constructor: ({@factory, @view, @element, @reader}) ->
    @placeholderElement = @element

    @subscribe @reader, 'value', (model) =>
      if model? and componentView = @factory.buildView(model)
        @element.parentNode.replaceChild(componentView.element, @element)
        @element = componentView.element
        @view.childViewDetached(@componentView) if @componentView?
        @view.childViewAttached(componentView)
        @componentView = componentView
      else
        @element.parentNode.replaceChild(@placeholderElement, @element)
        @element = @placeholderElement
        @view.childViewDetached(@componentView) if @componentView?
