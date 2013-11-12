{Model} = require 'telepath'
Template = require '../src/template'

describe "Template", ->
  template = null

  class Blog extends Model
  class Post extends Model
  class Comment extends Model

  beforeEach ->
    template = new Template

  describe "template selection", ->
    beforeEach ->
      template.name = "Blog"
      template.content = "<div>Blog</div>"
      template.register("Post", content: "<div>Post</div>")
      template.register("Comment", content: "<div>Comment</div>")

    describe "when the receiving template can build a view for the given model", ->
      it "constructs a view for itself", ->
        expect(template.build(new Blog).outerHTML).toBe "<div>Blog</div>"

    describe "when the receiving template cannot build a view for the given model", ->
      describe "when it has a subtemplate that can build a view for the given model", ->
        it "delegates construction to the subtemplate", ->
          expect(template.build(new Post).outerHTML).toBe "<div>Post</div>"
          expect(template.build(new Comment).outerHTML).toBe "<div>Comment</div>"

      describe "when it does *not* have a subtemplate that can build a view for the the model model", ->
        describe "when it has a parent template", ->
          it "delegates the call to its parent", ->
            expect(template.Post.build(new Comment).outerHTML).toBe "<div>Comment</div>"

        describe "when it is the root template", ->
          it "returns undefined", ->
            class Favorite
            expect(template.build(new Favorite)).toBeUndefined()

  describe "DOM fragment construction", ->
    beforeEach ->
      template.name = "Blog"

    describe "when the content property is a string", ->
      it "parses the string to a DOM fragment", ->
        template.content = "<div>Blog</div>"
        expect(template.build(new Blog).outerHTML).toBe "<div>Blog</div>"

    describe "when the content property is already a DOM fragment", ->
      it "clones the fragment", ->
        div = window.document.createElement("div")
        div.innerHTML = "<div>Blog!</div>"
        contentFragment = div.firstChild
        template.content = contentFragment

        fragment = template.build(new Blog)
        expect(fragment.outerHTML).toBe contentFragment.outerHTML
        expect(fragment).not.toBe contentFragment

    describe "when the content property is a function", ->
      beforeEach ->
        template.content = jasmine.createSpy("template.content")

      it "calls the function with the model", ->
        blog = new Blog
        template.build(blog)
        expect(template.content).toHaveBeenCalledWith(blog)

      describe "when the function returns a string", ->
        it "parses the string as a DOM fragment", ->
          template.content.andReturn("<div>Blog!</div>")
          expect(template.build(new Blog).outerHTML).toBe "<div>Blog!</div>"

      describe "when the function returns a DOM fragment", ->
        it "returns the DOM fragment", ->
          div = window.document.createElement("div")
          div.innerHTML = "<div>Blog!</div>"
          contentFragment = div.firstChild
          template.content.andReturn(contentFragment)
          expect(template.build(new Blog)).toBe contentFragment

      describe "when the function calls HTML tag methods", ->
        it "returns a DOM fragment based on the called tag methods", ->
          template.content = -> @div => @h1 "Hello World!"
          expect(template.build(new Blog).outerHTML).toBe "<div><h1>Hello World!</h1></div>"

  describe "bindings", ->
    describe "text", ->
      it "replaces the bound element's text content with the value of the bound property", ->
        Blog.property 'title'
        template.register 'Blog', content: ->
          @div => @h1 'tv-text': "title"

        blog = Blog.createAsRoot(title: "Alpha")
        node = template.build(blog)
        expect(node.outerHTML).toBe '<div><h1 tv-text="title">Alpha</h1></div>'
        blog.title = "Beta"
        expect(node.outerHTML).toBe '<div><h1 tv-text="title">Beta</h1></div>'
