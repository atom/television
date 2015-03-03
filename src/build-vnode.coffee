VNode = require 'virtual-dom/vnode/vnode'
VText = require 'virtual-dom/vnode/vtext'

module.exports = ->
  [tagName] = arguments
  if arguments[1]?.constructor is Object
    attributes = arguments[1]
    properties = {}
    if attributes.style?
      properties.style = attributes.style
      delete attributes.style

    if attributes.className?
      properties.className = attributes.className
      delete attributes.className

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

  node = new VNode(tagName, properties, children)
  node
