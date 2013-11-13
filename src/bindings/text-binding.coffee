{Subscriber} = require 'emissary'

module.exports =
class TextBinding
  Subscriber.includeInto(this)

  @type: 'text'

  constructor: (@element, @model, @propertyName) ->
    @subscribe @model["$#{@propertyName}"], 'value', (value) =>
      @element.textContent = value
