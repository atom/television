buildVirtualNode = require './build-virtual-node'
buildTagFunctions = require './build-tag-functions'
CustomElementPrototype = require './custom-element-prototype'

setDOMScheduler = (domScheduler) ->
  CustomElementPrototype.domScheduler = domScheduler

registerElement = (name, prototype) ->
  elementPrototype = Object.create(CustomElementPrototype)
  elementPrototype[key] = value for key, value of prototype
  document.registerElement(name, prototype: elementPrototype)

module.exports = {setDOMScheduler, buildTagFunctions, registerElement, buildVirtualNode}
