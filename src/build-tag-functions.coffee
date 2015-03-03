buildVirtualNode = require './build-virtual-node'

DEFAULT_TAG_NAMES =
  'a abbr address article aside audio b bdi bdo blockquote body button canvas
   caption cite code colgroup datalist dd del details dfn dialog div dl dt em
   fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header html i
   iframe ins kbd label legend li main map mark menu meter nav noscript object
   ol optgroup option output p pre progress q rp rt ruby s samp script section
   select small span strong style sub summary sup table tbody td textarea tfoot
   th thead time title tr u ul var video area base br col command embed hr img
   input keygen link meta param source track wbr'.split /\s+/

DEFAULT_TAG_FUNCTIONS = {}
for tagName in DEFAULT_TAG_NAMES
  do (tagName) ->
    DEFAULT_TAG_FUNCTIONS[tagName] = -> buildVirtualNode(tagName, arguments...)

module.exports = ->
  tags = {}

  for tagFunctionName in arguments
    tagName = tagFunctionName.replace(/([A-Z])/g, "-$1").replace(/^-/, "").toLowerCase()
    do (tagFunctionName, tagName) ->
      tags[tagFunctionName] = -> buildVirtualNode(tagName, arguments...)

  for tagName, tagFunction of DEFAULT_TAG_FUNCTIONS
    tags[tagName] = tagFunction

  tags
