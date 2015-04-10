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
    @subscribe()
    @node = createElement(@vnode)

  update: (previousWidget, node) ->
    if this isnt previousWidget
      previousWidget.unsubscribe()
      @subscribe(node)

    oldVnode = previousWidget.vnode
    @vnode = @getObservedVnode()
    @node = patch(node, diff(oldVnode, @vnode))

  destroy: ->
    @unsubscribe()

  getObservedVnode: ->
    value = @observation.getValue()
    if typeof value is 'string'
      new VText(value)
    else
      value

  subscribe: ->
    @observationDisposable =
      @observation.onChange =>
        @update(this, @node)

  unsubscribe: ->
    @observationDisposable.dispose()
