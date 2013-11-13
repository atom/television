{toArray} = require 'underscore'
TextBinding = require './bindings/text-binding'

module.exports =
class View
  constructor: (@template, @element, @model) ->
    @bindings = []
    @createBindings(@element)

  createBindings: (element) ->
    for child in element.children
      @createBindings(child)

    for attribute in element.attributes
      if match = attribute.name.match(/^tv-(.*)/)
        bindingType = match[1]
        @template.buildBinding(bindingType, element, @model, attribute.value)
