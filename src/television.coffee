buildVirtualNode = require './build-virtual-node'
buildTagFunctions = require './build-tag-functions'
CustomElementPrototype = require './custom-element-prototype'

elementConstructors = {}

setDOMScheduler = (domScheduler) ->
  CustomElementPrototype.domScheduler = domScheduler

registerElement = (name, prototype) ->
  elementPrototype = Object.create(CustomElementPrototype)
  elementPrototype[key] = value for key, value of prototype

  if elementConstructor = elementConstructors[name]
    Object.setPrototypeOf(elementConstructor.prototype, elementPrototype)
    elementConstructor
  else
    elementConstructors[name] = document.registerElement(name, prototype: Object.create(elementPrototype))

module.exports = {setDOMScheduler, buildTagFunctions, registerElement, buildVirtualNode}
