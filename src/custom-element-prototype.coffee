diff = require "virtual-dom/diff"
patch = require "virtual-dom/patch"

buildVirtualNode = require './build-virtual-node'

module.exports = Object.create HTMLElement.prototype,
  domScheduler: value: {
    readDocument: (fn) -> fn()
    updateDocument: (fn) -> fn()
  }

  createdCallback: value: ->
    @didCreate?()

  attachedCallback: value: ->
    @updateSync()
    @didAttach?()

  detachedCallback: value: ->
    @didDetach?()
    @innerHTML = ""

  update: value: ->
    @domScheduler.updateDocument(@updateSync.bind(this))
    @domScheduler.readDocument(@readSync.bind(this))

  updateSync: value: ->
    @oldVirtualDOM ?= buildVirtualNode(@tagName.toLowerCase())
    newVirtualDOM = @render()
    patch(this, diff(@oldVirtualDOM, newVirtualDOM))
    @oldVirtualDOM = newVirtualDOM

  readSync: value: ->
