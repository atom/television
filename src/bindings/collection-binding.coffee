{times} = require 'underscore'
Binding = require '../binding'

module.exports =
class CollectionBinding extends Binding
  @id: 'collection'

  constructor: ({@factory, @view, @element, @reader}) ->
    @componentViews = []

    @subscribe @reader, 'value', (collection) =>
      if @collection?
        @unsubscribe(@collection)
        @removeComponentViews(0, @componentViews.length)

      @collection = collection
      @element.innerHTML = ''

      @insertComponentViews(0, @viewsForModels(@collection.getValues()))

      @subscribe @collection, 'changed', ({index, removedValues, insertedValues}) =>
        @removeComponentViews(index, removedValues.length)
        @insertComponentViews(index, @viewsForModels(insertedValues))

  insertComponentViews: (index, componentViews) ->
    @componentViews.splice(index, 0, componentViews...)
    fragment = window.document.createDocumentFragment()
    fragment.appendChild(element) for {element} in componentViews
    @element.insertBefore(fragment, @element.children[index])
    @view.childViewsAttached(componentViews)

  removeComponentViews: (index, count) ->
    removedViews = @componentViews.splice(index, count)
    @element.removeChild(element) for {element} in removedViews
    @view.childViewsDetached(removedViews)

  viewsForModels: (models) ->
    models.map (model) => @factory.buildView(model)
