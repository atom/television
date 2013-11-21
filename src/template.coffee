{find, clone} = require 'underscore'
{Subscriber} = require 'emissary'
HTMLBuilder = require './html-builder'
View = require './view'

module.exports =
class Template
  Subscriber.includeInto(this)

  constructor: ({@name, @content, @parent}={}) ->
    @subtemplates = []
    @binders = {}
    @viewCache = new WeakMap
    unless @parent?
      @registerBinder('text', require('./bindings/text-binding'))
      @registerBinder('component', require('./bindings/component-binding'))
      @registerBinder('collection', require('./bindings/collection-binding'))

  register: (args...) ->
    name = args.shift() if typeof args[0] is 'string'
    params = clone(args.shift()) ? {}
    params.name = name if name?
    params.parent = this
    subtemplate = new @constructor(params)
    @subtemplates.push(subtemplate)
    @[subtemplate.name] = subtemplate

  registerBinder: (type, binder) ->
    @binders[type] = binder

  getBinder: (type) ->
    @binders[type] ? @parent?.getBinder(type)

  visualize: (model) ->
    if element = @getCachedElement(model)
      element
    else if @canVisualize(model)
      if element = @buildFragment(model)
        view = new View(this, element, model)
        @cacheView(view)
        element
      else
        throw new Error("Template did not specify content")
    else
      if subtemplate = find(@subtemplates, (f) -> f.canVisualize(model))
        subtemplate.visualize(model)
      else
        @parent?.visualize(model)

  canVisualize: (model) ->
    @name is model.constructor.name

  cacheView: (view) ->
    {model} = view
    @viewCache.set(model, []) unless @viewCache.has(model)
    @viewCache.get(model).push(view)

    @subscribe view, 'destroyed', =>
      views = @viewCache.get(model)
      views.splice(views.indexOf(view), 1)


  getCachedElement: (model) ->
    if views = @viewCache.get(model)
      for {element} in views
        return element unless element.parentNode?
    undefined

  bind: (type, element, model, propertyName) ->
    if binder = @getBinder(type)
      binder.bind(this, element, model, propertyName)

  unbind: (type, binding) ->
    if binder = @getBinder(type)
      binder.unbind(binding)

  buildFragment: (model) ->
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
