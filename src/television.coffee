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
    unless Object.getPrototypeOf(elementConstructor.prototype) is HTMLElement.prototype
      throw new Error("Already registered element '#{name}'. Call .unregisterElement() on its constructor first.")
    Object.setPrototypeOf(elementConstructor.prototype, elementPrototype)
    elementConstructor
  else
    elementConstructor = document.registerElement(name, prototype: Object.create(elementPrototype))
    elementConstructor.unregisterElement = ->
      if Object.getPrototypeOf(elementConstructor.prototype) is HTMLElement.prototype
        throw new Error("Already unregistered element '#{name}'.")
      Object.setPrototypeOf(elementConstructor.prototype, HTMLElement.prototype)
    elementConstructors[name] = elementConstructor

module.exports = {setDOMScheduler, buildTagFunctions, registerElement, buildVirtualNode}
