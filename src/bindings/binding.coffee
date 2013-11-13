{Subscriber} = require 'emissary'

module.exports =
class Binding
  Subscriber.includeInto(this)
