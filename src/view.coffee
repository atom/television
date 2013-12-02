{toArray, extend} = require 'underscore'
{Emitter, Subscriber} = require 'emissary'
ViewFactory = require './view-factory'
Mixin = require 'mixto'

module.exports =
class View extends Mixin
  ViewFactory.extend(this)
  Emitter.includeInto(this)
  Subscriber.includeInto(this)

  @buildViewInstance: ({model, element, factory, viewProperties}) ->
    new this(model, element, this, @viewProperties)

  constructor: (@model, @element, @factory, customProperties) ->
    unless @element?
      if @constructor.canBuildViewForModel(model)
        @element = @constructor.buildElement(model)
        @factory = @constructor
        @constructor.cacheView(this)
      else
        throw new Error("This view is not compatible with the given model")

    @childViews = []
    @bindings = []
    @createBindings(@element)
    @model.on 'detached', => @destroy()
    extend(this, customProperties) if customProperties?
    @created?()

  addChildViews: (views) ->
    @addChildView(view) for view in views

  addChildView: (view) ->
    @childViews.push(view)

  removeChildViews: (views) ->
    @removeChildView(view) for view in views

  removeChildView: (view) ->
    index = @childViews.indexOf(view)
    @childViews.splice(index, 1)

  viewForModel: (model) ->
    @viewsForModel(model)[0]

  viewsForModel: (model) ->
    views = []
    views.push(this) if @model is model
    for childView in @childViews
      views.push(childView.viewsForModel(model)...)
    views

  createBindings: (element=@element) ->
    @bindings ?= []

    for child in element.children
      @createBindings(child)

    for attribute in element.attributes
      if match = attribute.name.match(/^x-bind-(.*)/)
        type = match[1]
        binding = @factory.createBinding(type, this, element, @model, attribute.value)
        @bindings.push([type, binding])
        binding

      if attribute.value.indexOf("{{") isnt -1
        @bindings.push(@factory.createTemplateAttributeBinding(this, element, attribute, @model))

    if element.textContent.indexOf("{{") isnt -1
      @bindings.push(@factory.createTemplateTextBinding(this, element, @model))

  destroy: ->
    for [type, binding] in @bindings
      @factory.destroyBinding(type, binding)
    @destroyed?()
    @emit 'destroyed'
