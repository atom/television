{times} = require 'underscore'
Binding = require './binding'

module.exports =
class CollectionBinding extends Binding
  constructor: ({@factory, @element, @model, @propertyName}) ->
    if behavior = @model["$#{@propertyName}"]
      @subscribe behavior, 'value', @onCollectionAssigned
    else
      @onCollectionAssigned(@model[@propertyName])

  onCollectionAssigned: (collection) =>
    @unsubscribe(@collection) if @collection?
    @collection = collection

    @element.innerHTML = ''
    @element.appendChild(@elementsForModels(@collection.getValues()))
    @subscribe @collection, 'changed', ({index, removedValues, insertedValues}) =>
      times removedValues.length, => @element.removeChild(@element.children[index])
      @element.insertBefore(@elementsForModels(insertedValues), @element.children[index])

  elementsForModels: (models) ->
    fragment = window.document.createDocumentFragment()
    for model in models
      if {element} = @factory.viewForModel(model)
        fragment.appendChild(element)
    fragment
