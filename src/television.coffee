h = require "virtual-dom/h"
diff = require "virtual-dom/diff"
patch = require "virtual-dom/patch"
inflection = require "inflection"

WRAPPER_DIV = document.createElement("div")
DEFAULT_TAG_NAMES =
  'a abbr address article aside audio b bdi bdo blockquote body button canvas
   caption cite code colgroup datalist dd del details dfn dialog div dl dt em
   fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i
   iframe ins kbd label legend li main map mark menu meter nav noscript object
   ol optgroup option output p pre progress q rp rt ruby s samp script section
   select small span strong style sub summary sup table tbody td textarea tfoot
   th thead time title tr u ul var video area base br col command embed hr img
   input keygen link meta param source track wbr'.split /\s+/

defaultTagFunctions = {} # Computed at eval time at end of file

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
    tags = {}
    for tagFunctionName in arguments
      tagName = tagFunctionName.replace(/([A-Z])/g, "-$1").replace(/^-/, "").toLowerCase()
      tags[tagFunctionName] = @tag(tagName)
    for tagName, tagFunction of defaultTagFunctions
      tags[tagName] = tagFunction
    tags

  tag: (tagName) ->
    (args...) ->
      if args[0]?.constructor is Object
        h(tagName, args[0], args.slice(1))
      else
        h(tagName, args)

  registerElement: (name, prototype) ->
    elementPrototype = Object.create(TelevisionElementPrototype)
    elementPrototype[key] = value for key, value of prototype
    document.registerElement(name, prototype: elementPrototype)

  render: (vtree) ->
    WRAPPER_DIV.innerHTML = ""
    patch(WRAPPER_DIV, diff(h('div'), h('div', vtree)))
    WRAPPER_DIV.innerHTML

for tagName in DEFAULT_TAG_NAMES
  defaultTagFunctions[tagName] = module.exports.tag(tagName)
