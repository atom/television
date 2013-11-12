{extend, find} = require 'underscore'
HTMLBuilder = require './html-builder'

module.exports =
class Factory
  constructor: ({@name, @content, @parent}) ->
    @subfactories = []

  register: (name, params) ->
    subfactory = new @constructor(extend({name, parent: this}, params))
    @subfactories.push(subfactory)
    @[name] = subfactory

  build: (model) ->
    if @canBuild(model)
      @buildFragment(model)
    else
      if subfactory = find(@subfactories, (f) -> f.canBuild(model))
        subfactory.build(model)
      else
        @parent?.build(model)

  canBuild: (model) ->
    @name is model.constructor.name

  buildFragment: (model) ->
    switch typeof @content
      when 'string'
        @parseFragment(@content)
      when 'function'
        builder = new HTMLBuilder
        result = @content.call(builder, model)
        if builderResult = builder.toHTML()
          result = builderResult
        if typeof result is 'string'
          @parseFragment(result)
        else
          result
      else
        @content.cloneNode(true)

  parseFragment: (string) ->
    div = window.document.createElement('div')
    div.innerHTML = string
    div.firstChild
