{Subscriber} = require 'emissary'

module.exports =
class TextBinding
  Subscriber.includeInto(this)

  constructor: (@element, @model, @propertyName) ->
    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      @element.textContent = value
