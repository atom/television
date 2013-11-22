{find, clone, omit, extend} = require 'underscore'
Mixin = require 'mixto'
{Subscriber} = require 'emissary'
HTMLBuilder = require './html-builder'

TextBinding = require('./bindings/text-binding')
AttributeBinding = require('./bindings/attribute-binding')
ComponentBinding = require('./bindings/component-binding')
CollectionBinding = require('./bindings/collection-binding')

module.exports =
class ViewFactory extends Mixin
  Subscriber.includeInto(this)

  constructor: (params={}) ->
    {@name, @modelClassName, @content, @parent} = params
    @viewProperties = omit(params, 'name', 'content', 'parent')
    @registerDefaultBinders()

  extended: ->
    @registerDefaultBinders()

  registerDefaultBinders: ->
    @registerBinder(TextBinding)
    @registerBinder(AttributeBinding)
    @registerBinder(ComponentBinding)
    @registerBinder(CollectionBinding)

  getBinders: ->
    @binders ?= []

  getChildFactories: ->
    @childFactories ?= []

  getViewCache: ->
    @viewCache ?= new WeakMap

  buildViewFactory: (params) ->
    new @constructor(params)

  register: (factories...) ->
    for factory in factories
      factory = new @constructor(factory) if factory.constructor is Object
      factory.parent = this
      @getChildFactories().push(factory)
      @[factory.name] = factory

  registerBinder: (binder) ->
    @getBinders().push(binder)

  getBinder: (type) ->
    find @getBinders(), (binder) ->
      if typeof binder.type is 'string'
        binder.type is type
      else
        binder.type.test(type)

  viewForModel: (model) ->
    if view = @getCachedView(model)
      view
    else if @canBuildViewForModel(model)
      if element = @buildElement(model)
        @cacheView(new View(model, element, this, @viewProperties))
      else
        throw new Error("Template did not specify content")
    else
      if childFactory = find(@getChildFactories(), (f) -> f.canBuildViewForModel(model))
        childFactory.viewForModel(model)
      else
        @parent?.viewForModel(model)

  canBuildViewForModel: (model) ->
    if @modelClassName?
      @modelClassName is model.constructor.name
    else
      @name is "#{model.constructor.name}View"

  cacheView: (view) ->
    {model} = view
    viewCache = @getViewCache()
    viewCache.set(model, []) unless viewCache.has(model)
    views = viewCache.get(model)
    @subscribe view, 'destroyed', => views.splice(views.indexOf(view), 1)
    views.push(view)
    view

  getCachedView: (model) ->
    if views = @getViewCache().get(model)
      find views, (view) -> not view.element.parentNode?

  bind: (type, element, model, propertyName) ->
    if binder = @getBinder(type)
      binder.bind({factory: this, type, element, model, propertyName})

  unbind: (type, binding) ->
    if binder = @getBinder(type)
      binder.unbind(binding)

  buildElement: (model) ->
    switch typeof @content
      when 'string'
        @parseHTML(@content)
      when 'function'
        builder = new HTMLBuilder
        result = @content.call(builder, model)
        if builderResult = builder.toHTML()
          result = builderResult
        if typeof result is 'string'
          @parseHTML(result)
        else
          result
      else
        @content.cloneNode(true)

  parseHTML: (string) ->
    div = window.document.createElement('div')
    div.innerHTML = string
    element = div.firstChild
    div.removeChild(element)
    element

  buildHTML: (args..., fn) ->
    builder = new HTMLBuilder
    result = fn.call(builder, args...)
    builder.toHTML()

View = require './view'
