diff = require "virtual-dom/diff"
patch = require "virtual-dom/patch"

buildVirtualNode = require './build-virtual-node'
refsStack = require './refs-stack'

module.exports = Object.create HTMLElement.prototype,
  domScheduler:
    writable: true
    value:
      readDocument: (fn) -> fn()
      updateDocument: (fn) -> fn()

  createdCallback: value: ->
    @refs = {}
    @didCreate?()

  attachedCallback: value: ->
    @updateSync()
    @didAttach?()

  detachedCallback: value: ->
    @didDetach?()
    @innerHTML = ""
    @refs = {}

  update: value: ->
    @domScheduler.updateDocument(@updateSync.bind(this))
    @domScheduler.readDocument(@readSync.bind(this))

  updateSync:
    writable: true
    value: ->
      @oldVirtualDOM ?= buildVirtualNode(@tagName.toLowerCase())
      newVirtualDOM = @render()
      refsStack.push(@refs)
      patch(this, diff(@oldVirtualDOM, newVirtualDOM))
      refsStack.pop()
      @oldVirtualDOM = newVirtualDOM

  readSync:
    writable: true
    value: ->
