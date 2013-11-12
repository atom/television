tags = """
  a abbr address article aside audio b bdi bdo blockquote body button
  canvas caption cite code colgroup datalist dd del details dfn div dl dt em
  fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
  html i iframe ins kbd label legend li map mark menu meter nav noscript object
  ol optgroup option output p pre progress q rp rt ruby s samp script section
  select small span strong style sub summary sup table tbody td textarea tfoot
  th thead time title tr u ul video area base br col command embed hr img input
  keygen link meta param source track wbrk
""".split /\s+/

voidElements = """
  area base br col command embed hr img input keygen link meta param source
  track wbr
""".split /\s+/

module.exports =
class HTMLBuilder
  constructor: ->
    @document = []

  toHTML: ->
    @document.join('')

  for tagName in tags
    do (tagName) => @::[tagName] = (args...) -> @tag(tagName, args...)

  tag: (name, args...) ->
    params = @parseTagArguments(args)

    @openTag(name, params.attributes)

    if name in voidElements
      if (params.text? or params.content?)
        throw new Error("Self-closing tag #{name} cannot have text or content")
    else
      params.content?()
      @text(params.text) if params.text?
      @closeTag(name)

  text: (string) ->
    escapedString = string
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')

    @document.push escapedString

  raw: (string) ->
    @document.push string

  openTag: (name, attributes) ->
    attributePairs =
      for attributeName, value of attributes
        "#{attributeName}=\"#{value}\""

    attributesString =
      if attributePairs.length
        " " + attributePairs.join(" ")
      else
        ""

    @document.push "<#{name}#{attributesString}>"

  closeTag: (name) ->
    @document.push "</#{name}>"

  parseTagArguments: (args) ->
    params = {}
    for arg in args
      type = typeof(arg)
      if type is "function"
        params.content = arg
      else if type is "string" or type is "number"
        params.text = arg.toString()
      else
        params.attributes = arg
    params
