{find, clone, omit, extend} = require 'underscore'
Mixin = require 'mixto'
{Subscriber, Signal, combine} = require 'emissary'

HTMLBuilder = require './html-builder'
loadParser = require './load-parser'
TemplateParser = loadParser(__dirname, 'template-parser')
ExpressionParser = loadParser(__dirname, 'expression-parser')

TextBinding = require('./bindings/text-binding')
AttributeBinding = require('./bindings/attribute-binding')
StyleBinding = require('./bindings/style-binding')
ComponentBinding = require('./bindings/component-binding')
CollectionBinding = require('./bindings/collection-binding')
FocusBinding = require('./bindings/focus-binding')

AppendFormatter = require('./formatters/append-formatter')

module.exports =
class ViewFactory extends Mixin
  Subscriber.includeInto(this)

  constructor: (params={}) ->
    {@name, @modelClassName, @content, @parent} = params
    @viewProperties = omit(params, 'name', 'content', 'parent')
    @registerDefaultBinders()
    @registerDefaultFormatters()

  extended: ->
    @registerDefaultBinders()
    @registerDefaultFormatters()

  registerDefaultBinders: ->
    @registerBinder(TextBinding)
    @registerBinder(AttributeBinding)
    @registerBinder(StyleBinding)
    @registerBinder(ComponentBinding)
    @registerBinder(CollectionBinding)
    @registerBinder(FocusBinding)

  registerDefaultFormatters: ->
    @registerFormatter(AppendFormatter)

  getBinders: ->
    @binders ?= []

  getFormatters: ->
    @formatters ?= {}

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

  getBinder: (id) ->
    find @getBinders(), (binder) ->
      if typeof binder.id is 'string'
        binder.id is id
      else
        binder.id.test(id)

  registerFormatter: (formatter) ->
    @getFormatters()[formatter.id] = formatter

  getFormatter: (id) ->
    @getFormatters()[id] ? @parent?.getFormatter(id)

  buildView: (model) ->
    if view = @getCachedView(model)
      view
    else if @canBuildViewForModel(model)
      if element = @buildElement(model)
        @cacheView(new View(model, element, this, @viewProperties))
      else
        throw new Error("Template did not specify content")
    else
      if childFactory = find(@getChildFactories(), (f) -> f.canBuildViewForModel(model))
        childFactory.buildView(model)
      else
        @parent?.buildView(model)

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

  createBinding: (id, view, element, model, expression) ->
    if binder = @getBinder(id)
      reader = @createReader(model, expression)
      writer = @createWriter(model, expression)
      binder.bind({factory: this, id, view, element, reader, writer})

  destroyBinding: (id, binding) ->
    if binder = @getBinder(id)
      binder.unbind(binding)

  createTemplateTextBinding: (view, element, model) ->
    reader = @createReaderFromTemplate(element.textContent, model)
    @getBinder('text').bind({factory: this, id: 'text', view, element, reader})

  createTemplateAttributeBinding: (view, element, attribute, model) ->
    id = "attribute-#{attribute.name}"
    reader = @createReaderFromTemplate(attribute.value, model)
    @getBinder(id).bind({factory: this, id, view, element, reader})

  createReaderFromTemplate: (template, model) ->
    segments = TemplateParser.parse(template).map (segment) =>
      if typeof segment is 'string'
        segment
      else
        @createReader(model, segment.expression)
    combine(segments).map (segments) -> segments.join('')

  createReader: (model, expression) ->
    {property, formatters} = ExpressionParser.parse(expression)
    reader = model.behavior(property)
    for {id, args} in formatters
      if formatter = @getFormatter(id)
        reader = reader.map (value) -> formatter.read(value, args...)
    reader

  createWriter: (model, property) ->
    writer = new Signal
    writer.onValue (value) -> model.set(property, value)
    writer

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
