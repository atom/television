createElement = require 'virtual-dom/create-element'
diff = require 'virtual-dom/diff'
patch = require 'virtual-dom/patch'
VText = require 'virtual-dom/vnode/vtext'

module.exports =
class ObservationWidget
  type: "Widget"

  constructor: (@observation) ->

  init: ->
    @vnode = @getObservedVnode()
    node = createElement(@vnode)
    @subscribe(node)
    node

  update: (previousWidget, node) ->
    if this isnt previousWidget
      previousWidget.unsubscribe()
      @subscribe(node)

    oldVnode = previousWidget.vnode
    newVnode = @getObservedVnode()
    patch(node, diff(oldVnode, newVnode))
    @vnode = newVnode
    return

  destroy: ->
    @unsubscribe()

  getObservedVnode: ->
    value = @observation.getValue()
    if typeof value is 'string'
      new VText(value)
    else
      value

  subscribe: (node) ->
    @observationDisposable =
      @observation.onChange => @update(this, node)

  unsubscribe: ->
    @observationDisposable.dispose()
