{times} = require 'underscore'
Binding = require './binding'

module.exports =
class CollectionBinding extends Binding
  constructor: (@template, @element, @model, @propertyName) ->
    if behavior = @model["$#{@propertyName}"]
      @subscribe behavior, 'value', @onCollectionAssigned
    else
      @onCollectionAssigned(@model[@propertyName])

  onCollectionAssigned: (collection) =>
    @unsubscribe(@collection) if @collection?
    @collection = collection

    @element.innerHTML = ''
    @element.appendChild(@visualizeModels(@collection.getValues()))
    @subscribe @collection, 'changed', ({index, removedValues, insertedValues}) =>
      times removedValues.length, => @element.removeChild(@element.children[index])
      @element.insertBefore(@visualizeModels(insertedValues), @element.children[index])

  visualizeModels: (models) ->
    fragment = window.document.createDocumentFragment()
    for model in models
      if element = @template.visualize(model)
        fragment.appendChild(element)
    fragment
