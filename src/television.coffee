buildVirtualNode = require './build-virtual-node'
buildTagFunctions = require './build-tag-functions'
CustomElementPrototype = require './custom-element-prototype'

retargetablePrototypes = {}

setDOMScheduler = (domScheduler) ->
  CustomElementPrototype.domScheduler = domScheduler

registerElement = (name, prototype) ->
  elementPrototype = Object.create(CustomElementPrototype)
  elementPrototype[key] = value for key, value of prototype

  if retargetablePrototypes[name]
    Object.setPrototypeOf(retargetablePrototypes[name], elementPrototype)
  else
    retargetablePrototypes[name] = Object.create(elementPrototype)
    document.registerElement(name, prototype: retargetablePrototypes[name])

module.exports = {setDOMScheduler, buildTagFunctions, registerElement, buildVirtualNode}
