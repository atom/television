{Emitter, Disposable} = require 'event-kit'

module.exports =
class Observation
  subscriberCount: 0
  initDisposable: null

  constructor: (@value, @initFn) ->
    @emitter = new Emitter

  reportChange: (@value) =>
    @emitter.emit('change')

  getValue: -> @value

  onChange: (fn) ->
    @initDisposable ?= @initFn(@reportChange)
    @subscriberCount++
    subscribeDisposable = @emitter.on('change', fn)
    new Disposable =>
      subscribeDisposable.dispose()
      if --@subscriberCount is 0
        @initDisposable.dispose()
        @initDisposable = null

  map: (transform) ->
    source = this
    new Observation transform(source.getValue()), (reportChange) ->
      source.onChange -> reportChange(transform(source.getValue()))
