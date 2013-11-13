{Model} = require 'telepath'
Television = require '../src/television'

describe "Television", ->
  class Blog extends Model
  class Post extends Model
  class Comment extends Model

  tv = null

  beforeEach ->
    tv = new Television

  describe "template selection", ->
    beforeEach ->
      tv.addTemplate("Blog", content: "<div>Blog</div>")
      tv.Blog.addTemplate("Post", content: "<div>Post</div>")
      tv.Blog.addTemplate("Comment", content: "<div>Comment</div>")

    describe "when the receiving template can build a view for the given model", ->
      it "constructs a view for itself", ->
        expect(tv.Blog.build(new Blog).outerHTML).toBe "<div>Blog</div>"

    describe "when the receiving template cannot build a view for the given model", ->
      describe "when it has a subtemplate that can build a view for the given model", ->
        it "delegates construction to the subtemplate", ->
          expect(tv.Blog.build(new Post).outerHTML).toBe "<div>Post</div>"
          expect(tv.Blog.build(new Comment).outerHTML).toBe "<div>Comment</div>"

      describe "when it does *not* have a subtemplate that can build a view for the the model model", ->
        describe "when it has a parent template", ->
          it "delegates the call to its parent", ->
            expect(tv.Blog.Post.build(new Comment).outerHTML).toBe "<div>Comment</div>"

        describe "when it is the root template", ->
          it "returns undefined", ->
            class Favorite
            expect(tv.build(new Favorite)).toBeUndefined()

  describe "element construction", ->
    beforeEach ->
      tv.addTemplate("Blog")

    describe "when the content property is a string", ->
      it "parses the string to a DOM fragment", ->
        tv.Blog.content = "<div>Blog</div>"
        expect(tv.build(new Blog).outerHTML).toBe "<div>Blog</div>"

    describe "when the content property is already a DOM fragment", ->
      it "clones the fragment", ->
        div = window.document.createElement("div")
        div.innerHTML = "<div>Blog!</div>"
        contentFragment = div.firstChild
        tv.Blog.content = contentFragment

        fragment = tv.build(new Blog)
        expect(fragment.outerHTML).toBe contentFragment.outerHTML
        expect(fragment).not.toBe contentFragment

    describe "when the content property is a function", ->
      it "calls the function with the model", ->
        tv.Blog.content = jasmine.createSpy("template.content")
        blog = new Blog
        tv.build(blog)
        expect(tv.Blog.content).toHaveBeenCalledWith(blog)

      describe "when the function returns a string", ->
        it "parses the string as a DOM fragment", ->
          tv.Blog.content = -> "<div>Blog!</div>"
          expect(tv.build(new Blog).outerHTML).toBe "<div>Blog!</div>"

      describe "when the function returns a DOM fragment", ->
        it "returns the DOM fragment", ->
          div = window.document.createElement("div")
          div.innerHTML = "<div>Blog!</div>"
          contentFragment = div.firstChild
          tv.Blog.content = -> contentFragment
          expect(tv.build(new Blog)).toBe contentFragment

      describe "when the function calls HTML tag methods", ->
        it "returns a DOM fragment based on the called tag methods", ->
          tv.Blog.content = -> @div => @h1 "Hello World!"
          expect(tv.build(new Blog).outerHTML).toBe "<div><h1>Hello World!</h1></div>"

  describe "bindings", ->
    describe "text", ->
      it "replaces the bound element's text content with the value of the bound property", ->
        Blog.property 'title'
        tv.addTemplate 'Blog', content: ->
          @div => @h1 'tv-text': "title"

        blog = Blog.createAsRoot(title: "Alpha")
        node = tv.build(blog)
        expect(node.outerHTML).toBe '<div><h1 tv-text="title">Alpha</h1></div>'
        blog.title = "Beta"
        expect(node.outerHTML).toBe '<div><h1 tv-text="title">Beta</h1></div>'

    describe "component", ->
      it "replaces the bound element with a view based on the value of the bound property", ->
        Blog.property 'featuredItem'
        Post.property 'title'
        Comment.property 'body'

        tv.addTemplate 'Blog', content: ->
          @div =>
            @h1 "Featured Item"
            @div 'tv-component': "featuredItem"
        tv.addTemplate 'Post', content: -> @div id: 'post', 'tv-text': 'title'
        tv.addTemplate 'Comment', content: -> @div id: 'comment', 'tv-text': 'body'

        post = new Post(title: "Alpha")
        comment = new Comment(title: "Hello")
        blog = Blog.createAsRoot(featuredItem: post)

        element = tv.build(blog)
        expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div id="post" tv-text="title">Alpha</div></div>'
