tv = require '../src/television'
createElement = require 'virtual-dom/create-element'

attachToDocument = (element) ->
  document.getElementById('jasmine-content').appendChild(element)

describe "television", ->
  elementConstructor = null

  afterEach ->
    elementConstructor?.unregisterElement()
    elementConstructor = null
    document.getElementById('jasmine-content').innerHTML = ""

  describe ".registerElement(name, properties)", ->
    it "registers a custom element that updates based on the virtual DOM", ->
      {div, TelevisionTest} = tv.buildTagFunctions('TelevisionTest')

      elementConstructor = tv.registerElement 'television-test',
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

      elementConstructor = tv.registerElement 'television-test',
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

    it "assigns references to DOM nodes based on 'ref' attributes", ->
      {div, TelevisionTest} = tv.buildTagFunctions('TelevisionTest')

      elementConstructor = tv.registerElement 'television-test',
        foo: true

        render: ->
          TelevisionTest(
            div ref: "div1", className: "div-1"
            div ref: "div2", className: "div-2" if @foo
          )

      element = document.createElement('television-test')
      attachToDocument(element)

      expect(element.refs.div1.classList.contains("div-1")).toBe true
      expect(element.refs.div2.classList.contains("div-2")).toBe true

      element.foo = false
      element.updateSync()
      expect(element.refs.div1.classList.contains("div-1")).toBe true
      expect(element.refs.div2).toBeUndefined()

    it "interacts with the assigned DOM update scheduler on calls to ::update to update and read the DOM", ->
      {div, TelevisionTest} = tv.buildTagFunctions('TelevisionTest')

      elementConstructor = tv.registerElement 'television-test',
        updateSyncCalled: false
        readSyncCalled: false

        updateSync: ->
          @updateSyncCalled = true

        readSync: ->
          @readSyncCalled = true

      element = document.createElement('television-test')

      updateFns = []
      readFns = []

      tv.setDOMScheduler(
        updateDocument: (fn) -> updateFns.push(fn)
        readDocument: (fn) -> readFns.push(fn)
      )

      element.update()
      expect(updateFns.length).toBe 1
      expect(readFns.length).toBe 1

      expect(element.updateSyncCalled).toBe false
      expect(element.readSyncCalled).toBe false

      updateFns[0]()
      expect(element.updateSyncCalled).toBe true
      expect(element.readSyncCalled).toBe false

      readFns[0]()
      expect(element.updateSyncCalled).toBe true
      expect(element.readSyncCalled).toBe true

    it "throws an exception if the same element name is registered without the previous being unregistered", ->
      {TelevisionTest} = tv.buildTagFunctions('TelevisionTest')
      elementConstructor = tv.registerElement 'television-test', render: -> TelevisionTest("Hello")
      expect(-> tv.registerElement 'television-test', render: -> TelevisionTest("Goodbye")).toThrow()
      elementConstructor.unregisterElement()
      expect(-> elementConstructor.unregisterElement()).toThrow()
      elementConstructor = tv.registerElement 'television-test', render: -> TelevisionTest("Hello Again")

  describe ".buildTagFunctions(tagNames...)", ->
    it "returns an object with functions for all the HTML tags, plus any named custom tags", ->
      {ChatPanel, div, span, img} = tv.buildTagFunctions('ChatPanel')

      expect(createElement(ChatPanel()).outerHTML).toBe """
        <chat-panel></chat-panel>
      """
      expect(createElement(div(className: "hello", span("hello"))).outerHTML).toBe """
        <div class="hello"><span>hello</span></div>
      """

      expect(createElement(img(src: "/foo/bar.png")).outerHTML).toBe """
        <img src="/foo/bar.png">
      """
