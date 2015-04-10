{Emitter} = require 'event-kit'

module.exports =
class Observation
  constructor: (@value, initFn) ->
    @emitter = new Emitter
    initFn(@reportChange)

  reportChange: (@value) =>
    @emitter.emit('change')

  getValue: -> @value

  onChange: (fn) -> @emitter.on('change', fn)

  map: (transform) ->
    source = this
    new Observation transform(source.getValue()), (reportChange) ->
      source.onChange -> reportChange(transform(source.getValue()))
