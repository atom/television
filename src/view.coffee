{toArray, extend} = require 'underscore'
{Emitter} = require 'emissary'
ViewFactory = require './view-factory'

module.exports =
class View
  ViewFactory.extend(this)
  Emitter.includeInto(this)

  constructor: (@model, @element, @factory, customProperties) ->
    unless @element?
      if @constructor.canBuildViewForModel(model)
        @element = @constructor.buildElement(model)
        @factory = @constructor
        @constructor.cacheView(this)
      else
        throw new Error("This view is not compatible with the given model")

    extend(this, customProperties) if customProperties?
    @bindings = []
    @createBindings(@element)
    @model.on 'detached', => @destroy()
    @created?()

  createBindings: (element) ->
    for child in element.children
      @createBindings(child)

    for attribute in element.attributes
      if match = attribute.name.match(/^x-bind-(.*)/)
        bindingType = match[1]
        binding = @factory.bind(bindingType, element, @model, attribute.value)
        @bindings.push([bindingType, binding])
        binding

  destroy: ->
    for [bindingType, binding] in @bindings
      @factory.unbind(bindingType, binding)
    @destroyed?()
    @emit 'destroyed'
