{extend, find} = require 'underscore'
HTMLBuilder = require './html-builder'
View = require './view'

module.exports =
class Template
  constructor: ({@name, @content, @parent}={}) ->
    @subtemplates = []
    @bindingClasses = {}
    unless @parent?
      @addBindingClass(require './bindings/text-binding')
      @addBindingClass(require './bindings/component-binding')

  register: (name, params) ->
    subtemplate = new @constructor(extend({name, parent: this}, params))
    @subtemplates.push(subtemplate)
    @[name] = subtemplate

  addBindingClass: (bindingClass) ->
    @bindingClasses[bindingClass.type] = bindingClass

  build: (model) ->
    if @canBuild(model)
      element = @buildFragment(model)
      new View(this, element, model) if element?
      element
    else
      if subtemplate = find(@subtemplates, (f) -> f.canBuild(model))
        subtemplate.build(model)
      else
        @parent?.build(model)

  canBuild: (model) ->
    @name is model.constructor.name

  buildBinding: (type, element, model, propertyName) ->
    if BindingClass = @bindingClasses[type]
      new BindingClass(this, element, model, propertyName)
    else
      @parent?.buildBinding(type, element, model, propertyName)

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
