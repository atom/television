Binding = require './binding'

module.exports =
class ComponentBinding extends Binding

  @type: 'component'

  constructor: (@template, @element, @model, @propertyName) ->
    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      component = @template.build(value)
      @element.parentNode.replaceChild(component, @element)
      @element = component
