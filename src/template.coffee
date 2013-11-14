{extend, find} = require 'underscore'
HTMLBuilder = require './html-builder'
View = require './view'

module.exports =
class Template
  constructor: ({@name, @content, @parent}={}) ->
    @subtemplates = []
    @binders = {}
    unless @parent?
      @registerBinder('text', require('./bindings/text-binding'))
      @registerBinder('component', require('./bindings/component-binding'))

  register: (name, params) ->
    subtemplate = new @constructor(extend({name, parent: this}, params))
    @subtemplates.push(subtemplate)
    @[name] = subtemplate

  registerBinder: (type, binder) ->
    @binders[type] = binder

  getBinder: (type) ->
    @binders[type] ? @parent?.getBinder(type)

  visualize: (model) ->
    if @canVisualize(model)
      element = @buildFragment(model)
      new View(this, element, model) if element?
      element
    else
      if subtemplate = find(@subtemplates, (f) -> f.canVisualize(model))
        subtemplate.visualize(model)
      else
        @parent?.visualize(model)

  canVisualize: (model) ->
    @name is model.constructor.name

  bind: (type, element, model, propertyName) ->
    if binder = @getBinder(type)
      binder.bind(this, element, model, propertyName)

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
    div.firstChild

  buildHTML: (args..., fn) ->
    builder = new HTMLBuilder
    result = fn.call(builder, args...)
    builder.toHTML()
