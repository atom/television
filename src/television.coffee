h = require 'virtual-dom/h'
diff = require "virtual-dom/diff"
patch = require "virtual-dom/patch"

TelevisionElementPrototype = Object.create HTMLElement.prototype,
  createdCallback: value: ->

  attachedCallback: value: ->
    @updateSync()

  detachedCallback: value: ->
    @innerHTML = ""

  updateSync: value: ->
    @oldVirtualDOM ?= h(@tagName.toLowerCase())
    newVirtualDOM = @render()
    patch(this, diff(@oldVirtualDOM, newVirtualDOM))
    @oldVirtualDOM = newVirtualDOM

module.exports =
  tags: ->
    @tag(tagName) for tagName in arguments

  tag: (tagName) ->
    (args...) ->
      if args[0].constructor is Object
        h(tagName, args[0], args.slice(1))
      else
        h(tagName, args)

  registerElement: (name, prototype) ->
    elementPrototype = Object.create(TelevisionElementPrototype)
    elementPrototype[key] = value for key, value of prototype
    document.registerElement(name, prototype: elementPrototype)
