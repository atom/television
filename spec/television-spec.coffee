tv = require '../src/television'
createElement = require 'virtual-dom/create-element'

attachToDocument = (element) ->
  document.getElementById('jasmine-content').appendChild(element)

describe "television", ->
  afterEach ->
    document.getElementById('jasmine-content').innerHTML = ""

  describe ".registerElement(name, properties)", ->
    it "registers a custom element that updates based on the virtual DOM", ->
      {div, TelevisionTest} = tv.buildTagFunctions('TelevisionTest')
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

    it "calls lifecyle hooks on the custom element", ->
      {div, TelevisionTest} = tv.buildTagFunctions('TelevisionTest')
      tv.registerElement 'television-test',
        didCreateHookCalled: false
        didAttachHookCalled: false
        didDetachHookCalled: false

        render: ->
          TelevisionTest(div "Hello World!")

        didCreate: ->
          @didCreateHookCalled = true

        didAttach: ->
          @didAttachHookCalled = true

        didDetach: ->
          @didDetachHookCalled = true

      element = document.createElement('television-test')
      expect(element.didCreateHookCalled).toBe true
      expect(element.didAttachHookCalled).toBe false
      expect(element.didDetachHookCalled).toBe false

      attachToDocument(element)
      expect(element.didCreateHookCalled).toBe true
      expect(element.didAttachHookCalled).toBe true
      expect(element.didDetachHookCalled).toBe false

      element.remove()
      expect(element.didCreateHookCalled).toBe true
      expect(element.didAttachHookCalled).toBe true
      expect(element.didDetachHookCalled).toBe true

  describe ".buildTagFunctions(tagNames...)", ->
    it "returns an object with functions for all the HTML tags, plus any named custom tags", ->
      {ChatPanel, div, span} = tv.buildTagFunctions('ChatPanel')

      expect(createElement(ChatPanel()).outerHTML).toBe """
        <chat-panel></chat-panel>
      """
      expect(createElement(div(className: "hello", span("hello"))).outerHTML).toBe """
        <div class="hello"><span>hello</span></div>
      """
