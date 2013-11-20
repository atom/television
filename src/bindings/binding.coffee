{Subscriber} = require 'emissary'

module.exports =
class Binding
  Subscriber.includeInto(this)

  @bind: (args...) -> new this(args...)

  @unbind: (binding) -> binding.destroy()

  destroy: ->
    @unsubscribe()
