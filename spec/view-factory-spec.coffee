{Model, Document} = require 'telepath'
ViewFactory = require '../src/view-factory'
{parseHTML} = ViewFactory::

describe "ViewFactory", ->
  [Blog, Post, Comment] = []

  beforeEach ->
    class Blog extends Model
    class Post extends Model
    class Comment extends Model

  describe "view construction", ->
    it "builds the view with the current factory if it matches the model, but otherwise delegates to a matching immediate child or its parent", ->
      factory = new ViewFactory(name: "BlogView", content: "<div>Blog</div>")
      factory.register(name: "PostView", content: "<div>Post</div>")
      factory.register(name: "CommentView", content: "<div>Comment</div>")

      expect(factory.buildView(new Blog).element.textContent).toBe "Blog"
      expect(factory.buildView(new Post).element.textContent).toBe "Post"
      expect(factory.CommentView.buildView(new Blog).element.textContent).toBe "Blog"
      expect(factory.CommentView.buildView(new Post).element.textContent).toBe "Post"

    it "matches against the 'modelClassName' property if one is present", ->
      factory = new ViewFactory(name: "SomeKindaView", modelClassName: "Blog", content: "<div>Blog</div>")
      expect(factory.buildView(new Blog).element.textContent).toBe "Blog"

  describe "element construction based on the 'content' property", ->
    blog = null

    beforeEach ->
      blog = Blog.createAsRoot()

    describe "if the factory's 'content' property is a string", ->
      it "parses the string as HTML", ->
        factory = new ViewFactory(name: "BlogView", content: "<div>Blog</div>")
        {element} = factory.buildView(blog)
        expect(element.outerHTML).toBe "<div>Blog</div>"

    describe "if the factory's 'content' property is an element", ->
      it "clones the element", ->
        factory = new ViewFactory(name: "BlogView", content: parseHTML("<div>Blog</div>"))
        {element} = factory.buildView(blog)
        expect(element.outerHTML).toBe "<div>Blog</div>"
        expect(element).not.toBe factory.content

    describe "if the factory's 'content' property is a function", ->
      it "passes the model object to the function", ->
        contentFn = jasmine.createSpy("content").andReturn("<div>Blog</div>")
        factory = new ViewFactory(name: "BlogView", content: contentFn)
        factory.buildView(blog)
        expect(contentFn).toHaveBeenCalledWith(blog)

      describe "if the function returns a string", ->
        it "parses the string as HTML", ->
          factory = new ViewFactory(name: "BlogView", content: -> "<div>Blog</div>")
          {element} = factory.buildView(blog)
          expect(element.outerHTML).toBe "<div>Blog</div>"

      describe "if the function returns an element", ->
        it "builds the view with the returned element", ->
          contentElement = parseHTML("<div>Blog</div>")
          factory = new ViewFactory(name: "BlogView", content: -> contentElement)
          {element} = factory.buildView(blog)
          expect(element).toBe contentElement

      describe "if the function calls HTML builder DSL methods", ->
        it "builds the element based on the described HTML", ->
          factory = new ViewFactory
            name: "BlogView"
            content: ->
              @div =>
                @h1 "Hello World!"
          {element} = factory.buildView(blog)
          expect(element.outerHTML).toBe "<div><h1>Hello World!</h1></div>"

  describe "view caching", ->
    it "caches views until their model is detached", ->
      Blog.property 'title'
      doc = Document.create()
      blog = doc.set('blog', new Blog(title: "Alpha"))

      factory = new ViewFactory(name: "BlogView", content: "<div x-bind-text='title'></div>")

      expect(blog.state.getSubscriptionCount('changed')).toBe 0

      blogView1 = factory.buildView(blog)

      expect(blog.state.getSubscriptionCount('changed')).toBe 1

      expect(factory.buildView(blog)).toBe blogView1

      parentElement = window.document.createElement("div")
      parentElement.appendChild(blogView1.element)

      blogView2 = factory.buildView(blog)
      expect(blogView2).not.toBe blogView1
      expect(factory.buildView(blog)).toBe blogView2

      parentElement.appendChild(blogView2.element)
      expect(factory.buildView(blog)).not.toBe blogView1
      expect(factory.buildView(blog)).not.toBe blogView2

      parentElement.removeChild(blogView1.element)
      expect(factory.buildView(blog)).toBe blogView1

      # clear out cache when the model is detached
      doc.remove('blog')
      expect(factory.getCachedView(blog)).toBeUndefined()
      expect(blog.state.getSubscriptionCount()).toBe 0

  describe "custom view properties", ->
    it "extends the constructed view with properties registered on the factory", ->
      factory = new ViewFactory
        name: "BlogView"
        content: "<div>Blog</div>"
        foo: -> @fooCalled = true

      view = factory.buildView(new Blog)
      expect(view.foo()).toBe true
      expect(view.fooCalled).toBe true

    it "calls ::created and ::destroyed hooks when the view is created/destroyed", ->
      factory = new ViewFactory
        name: "BlogView"
        content: "<div>Blog</div>"
        created: -> @createdCalled = true
        destroyed: -> @destroyedCalled = true

      doc = Document.create()
      blog = doc.set('blog', new Blog)

      view = factory.buildView(blog)
      expect(view.createdCalled).toBe true
      expect(view.destroyedCalled).toBeUndefined()

      doc.remove('blog')
      expect(view.destroyedCalled).toBe true
