tv = require '../src/television'
{div, TelevisionTest} = tv.tags('TelevisionTest')

attachToDocument = (element) ->
  document.getElementById('jasmine-content').appendChild(element)

describe "television", ->
  afterEach ->
    document.getElementById('jasmine-content').innerHTML = ""

  it "allows you to create elements that update using the virtual DOM", ->
    tv.registerElement 'television-test',
      subject: "World"

      render: ->
        TelevisionTest(
          div "Hello #{@subject}!"
          div className: "subtitle", "How Are You?" if @includeSubtitle
        )

    element = document.createElement('television-test')
    attachToDocument(element)
    expect(element.outerHTML).toBe """
      <television-test><div>Hello World!</div></television-test>
    """

    element.subject = "Moon"
    element.updateSync()
    expect(element.outerHTML).toBe """
      <television-test><div>Hello Moon!</div></television-test>
    """

    element.includeSubtitle = true
    element.updateSync()
    expect(element.outerHTML).toBe """
      <television-test><div>Hello Moon!</div><div class="subtitle">How Are You?</div></television-test>
    """

  describe ".tags(tagNames...)", ->
    it "returns an object with functions for all the HTML tags, plus any named custom tags", ->
      {ChatPanel, div, span} = tv.tags('ChatPanel')
      expect(tv.render(ChatPanel())).toBe "<chat-panel></chat-panel>"
      expect(tv.render(div(span("hello")))).toBe "<div><span>hello</span></div>"
