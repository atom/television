{Emitter} = require 'event-kit'

module.exports =
class Observation
  constructor: (fn) ->
    @emitter = new Emitter
    fn (value) =>
      @value = value
      @emitter.emit('change')

  getValue: -> @value

  onChange: (fn) -> @emitter.on('change', fn)

  map: (transform) ->
    source = this
    new Observation (setValue) ->
      setValue(transform(source.getValue()))
      source.onChange -> setValue(transform(source.getValue()))
