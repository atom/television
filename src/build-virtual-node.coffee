VNode = require 'virtual-dom/vnode/vnode'
VText = require 'virtual-dom/vnode/vtext'

Observation = require './observation'
ObservationWidget = require './observation-widget'
refsStack = require './refs-stack'

class RefHook
  constructor: (@refName) ->
  hook: (node) ->
    if refs = refsStack[refsStack.length - 1]
      refs[@refName] = node
  unhook: (node) ->
    if refs = refsStack[refsStack.length - 1]
      delete refs[@refName]

module.exports = ->
  [tagName] = arguments
  if arguments[1]?.constructor is Object
    properties = arguments[1]
    properties.ref = new RefHook(properties.ref) if properties.ref?
    childrenIndex = 2
  else
    childrenIndex = 1

  children = []
  for i in [childrenIndex...arguments.length] by 1
    child = arguments[i]
    if typeof child is 'string'
      children.push(new VText(child))
    else if typeof child is 'number'
      children.push(new VText(child.toString()))
    else if child instanceof VNode
      children.push(child)
    else if child instanceof Observation
      children.push(new ObservationWidget(child))

  node = new VNode(tagName, properties, children)
  node
