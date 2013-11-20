{toArray} = require 'underscore'
{Emitter} = require 'emissary'
TextBinding = require './bindings/text-binding'

module.exports =
class View
  Emitter.includeInto(this)

  constructor: (@template, @element, @model) ->
    @bindings = []
    @createBindings(@element)
    @model.on 'detached', => @destroy()

  createBindings: (element) ->
    for child in element.children
      @createBindings(child)

    for attribute in element.attributes
      if match = attribute.name.match(/^x-bind-(.*)/)
        bindingType = match[1]
        binding = @template.bind(bindingType, element, @model, attribute.value)
        @bindings.push([bindingType, binding])
        binding

  destroy: ->
    for [bindingType, binding] in @bindings
      @template.unbind(bindingType, binding)
    @emit 'destroyed'
