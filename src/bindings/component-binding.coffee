Binding = require '../binding'

module.exports =
class ComponentBinding extends Binding
  @id: 'component'

  constructor: ({@factory, @view, @element, @reader}) ->
    @placeholderElement = @element
    @componentView = null

    @subscribe @reader, 'value', (model) =>
      parentNode = @element.parentNode
      nextSibling = @element.nextSibling
      parentNode.removeChild(@element)
      @element = null
      if @componentView?
        @view.childViewDetached(@componentView)
        @componentView = null

      if model? and componentView = @factory.buildView(model)
        @componentView = componentView
        @element = @componentView.element
        parentNode.insertBefore(@element, nextSibling)
        @view.childViewAttached(@componentView)
      else
        @element = @placeholderElement
        parentNode.insertBefore(@element, nextSibling)
