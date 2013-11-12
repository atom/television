TextBinding = require './bindings/text-binding'

module.exports =
class View
  constructor: (@element, @model) ->
    @bindings = []
    @createBindings(@element)

  createBindings: (element) ->
    @createBindings(element) for element in element.children

    for attribute in element.attributes
      if match = attribute.name.match(/^tv-(.*)/)
        bindingName = match[1]
        switch bindingName
          when 'text'
            @bindings.push(new TextBinding(element, @model, attribute.value))
