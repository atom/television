tv = require '../src/television'
[div, TVTest] = tv.tags('div', 'tv-test')

attachToDocument = (element) ->
  document.getElementById('jasmine-content').appendChild(element)

describe "foo", ->
  afterEach ->
    document.getElementById('jasmine-content').innerHTML = ""

  it "allows you to create elements that update using the virtual DOM", ->
    tv.registerElement 'tv-test',
      subject: "World"

      render: ->
        TVTest(
          div "Hello #{@subject}!"
          div className: "subtitle", "How Are You?" if @includeSubtitle
        )

    element = document.createElement('tv-test')
    attachToDocument(element)
    expect(element.outerHTML).toBe """
      <tv-test><div>Hello World!</div></tv-test>
    """

    element.subject = "Moon"
    element.updateSync()
    expect(element.outerHTML).toBe """
      <tv-test><div>Hello Moon!</div></tv-test>
    """

    element.includeSubtitle = true
    element.updateSync()
    expect(element.outerHTML).toBe """
      <tv-test><div>Hello Moon!</div><div class="subtitle">How Are You?</div></tv-test>
    """
