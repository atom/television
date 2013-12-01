{toArray, extend} = require 'underscore'
{Emitter, Subscriber} = require 'emissary'
ViewFactory = require './view-factory'

module.exports =
class View
  ViewFactory.extend(this)
  Emitter.includeInto(this)
  Subscriber.includeInto(this)

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
        type = match[1]
        binding = @factory.createBinding(type, element, @model, attribute.value)
        @bindings.push([type, binding])
        binding

      if attribute.value.indexOf("{{") isnt -1
        @bindings.push(@factory.createTemplateAttributeBinding(element, attribute, @model))

    if element.textContent.indexOf("{{") isnt -1
      @bindings.push(@factory.createTemplateTextBinding(element, @model))

  destroy: ->
    for [type, binding] in @bindings
      @factory.destroyBinding(type, binding)
    @destroyed?()
    @emit 'destroyed'
