{Model} = require 'telepath'
Factory = require '../src/factory'

describe "Factory", ->
  factory = null

  class Blog extends Model
  class Post extends Model
  class Comment extends Model

  beforeEach ->
    factory = new Factory

  describe "factory selection", ->
    beforeEach ->
      factory.name = "Blog"
      factory.content = "<div>Blog</div>"
      factory.register("Post", content: "<div>Post</div>")
      factory.register("Comment", content: "<div>Comment</div>")

    describe "when the receiving factory can build a view for the given model", ->
      it "constructs a view for itself", ->
        expect(factory.build(new Blog).outerHTML).toBe "<div>Blog</div>"

    describe "when the receiving factory cannot build a view for the given model", ->
      describe "when it has a subfactory that can build a view for the given model", ->
        it "delegates construction to the subfactory", ->
          expect(factory.build(new Post).outerHTML).toBe "<div>Post</div>"
          expect(factory.build(new Comment).outerHTML).toBe "<div>Comment</div>"

      describe "when it does *not* have a subfactory that can build a view for the the model model", ->
        describe "when it has a parent factory", ->
          it "delegates the call to its parent", ->
            expect(factory.Post.build(new Comment).outerHTML).toBe "<div>Comment</div>"

        describe "when it is the root factory", ->
          it "returns undefined", ->
            class Favorite
            expect(factory.build(new Favorite)).toBeUndefined()

  describe "DOM fragment construction", ->
    beforeEach ->
      factory.name = "Blog"

    describe "when the content property is a string", ->
      it "parses the string to a DOM fragment", ->
        factory.content = "<div>Blog</div>"
        expect(factory.build(new Blog).outerHTML).toBe "<div>Blog</div>"

    describe "when the content property is already a DOM fragment", ->
      it "clones the fragment", ->
        div = window.document.createElement("div")
        div.innerHTML = "<div>Blog!</div>"
        contentFragment = div.firstChild
        factory.content = contentFragment

        fragment = factory.build(new Blog)
        expect(fragment.outerHTML).toBe contentFragment.outerHTML
        expect(fragment).not.toBe contentFragment

    describe "when the content property is a function", ->
      beforeEach ->
        factory.content = jasmine.createSpy("factory.content")

      it "calls the function with the model", ->
        blog = new Blog
        factory.build(blog)
        expect(factory.content).toHaveBeenCalledWith(blog)

      describe "when the function returns a string", ->
        it "parses the string as a DOM fragment", ->
          factory.content.andReturn("<div>Blog!</div>")
          expect(factory.build(new Blog).outerHTML).toBe "<div>Blog!</div>"

      describe "when the function returns a DOM fragment", ->
        it "returns the DOM fragment", ->
          div = window.document.createElement("div")
          div.innerHTML = "<div>Blog!</div>"
          contentFragment = div.firstChild
          factory.content.andReturn(contentFragment)
          expect(factory.build(new Blog)).toBe contentFragment

      describe "when the function calls HTML tag methods", ->
        it "returns a DOM fragment based on the called tag methods", ->
          factory.content = -> @div => @h1 "Hello World!"
          expect(factory.build(new Blog).outerHTML).toBe "<div><h1>Hello World!</h1></div>"

  describe "bindings", ->
    describe "text", ->
      it "replaces the bound element's text content with the value of the bound property", ->
        Blog.property 'title'
        factory.register 'Blog', content: ->
          @div => @h1 'tv-text': "title"

        blog = Blog.createAsRoot(title: "Alpha")
        node = factory.build(blog)
        expect(node.outerHTML).toBe '<div><h1 tv-text="title">Alpha</h1></div>'
        blog.title = "Beta"
        expect(node.outerHTML).toBe '<div><h1 tv-text="title">Beta</h1></div>'
