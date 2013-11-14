{Model} = require 'telepath'
television = require '../src/television'

describe "Television", ->
  [tv, Blog, Post, Comment] = []

  beforeEach ->
    class Blog extends Model
    class Post extends Model
    class Comment extends Model
    tv = television()

  describe "template selection", ->
    beforeEach ->
      tv.register("Blog", content: "<div>Blog</div>")
      tv.Blog.register("Post", content: "<div>Post</div>")
      tv.Blog.register("Comment", content: "<div>Comment</div>")

    describe "when the receiving template can visualize the given model", ->
      it "constructs a view for itself", ->
        expect(tv.Blog.visualize(new Blog).outerHTML).toBe "<div>Blog</div>"

    describe "when the receiving template cannot visualize the given model", ->
      describe "when it has a subtemplate that can visualize the given model", ->
        it "delegates construction to the subtemplate", ->
          expect(tv.Blog.visualize(new Post).outerHTML).toBe "<div>Post</div>"
          expect(tv.Blog.visualize(new Comment).outerHTML).toBe "<div>Comment</div>"

      describe "when it does *not* have a subtemplate that can visualize the the model model", ->
        describe "when it has a parent template", ->
          it "delegates the call to its parent", ->
            expect(tv.Blog.Post.visualize(new Comment).outerHTML).toBe "<div>Comment</div>"

        describe "when it is the root template", ->
          it "returns undefined", ->
            class Favorite
            expect(tv.visualize(new Favorite)).toBeUndefined()

  describe "element construction", ->
    beforeEach ->
      tv.register("Blog")

    describe "when the content property is a string", ->
      it "parses the string to a DOM fragment", ->
        tv.Blog.content = "<div>Blog</div>"
        expect(tv.visualize(new Blog).outerHTML).toBe "<div>Blog</div>"

    describe "when the content property is already a DOM fragment", ->
      it "clones the fragment", ->
        div = window.document.createElement("div")
        div.innerHTML = "<div>Blog!</div>"
        contentFragment = div.firstChild
        tv.Blog.content = contentFragment

        fragment = tv.visualize(new Blog)
        expect(fragment.outerHTML).toBe contentFragment.outerHTML
        expect(fragment).not.toBe contentFragment

    describe "when the content property is a function", ->
      it "calls the function with the model", ->
        tv.Blog.content = jasmine.createSpy("template.content")
        blog = new Blog
        tv.visualize(blog)
        expect(tv.Blog.content).toHaveBeenCalledWith(blog)

      describe "when the function returns a string", ->
        it "parses the string as a DOM fragment", ->
          tv.Blog.content = -> "<div>Blog!</div>"
          expect(tv.visualize(new Blog).outerHTML).toBe "<div>Blog!</div>"

      describe "when the function returns a DOM fragment", ->
        it "returns the DOM fragment", ->
          div = window.document.createElement("div")
          div.innerHTML = "<div>Blog!</div>"
          contentFragment = div.firstChild
          tv.Blog.content = -> contentFragment
          expect(tv.visualize(new Blog)).toBe contentFragment

      describe "when the function calls HTML tag methods", ->
        it "returns a DOM fragment based on the called tag methods", ->
          tv.Blog.content = -> @div => @h1 "Hello World!"
          expect(tv.visualize(new Blog).outerHTML).toBe "<div><h1>Hello World!</h1></div>"

  describe "bindings", ->
    describe "text", ->
      it "replaces the bound element's text content with the value of the bound property", ->
        Blog.property 'title'
        tv.register 'Blog', content: ->
          @div => @h1 'x-bind-text': "title"

        blog = Blog.createAsRoot(title: "Alpha")
        node = tv.visualize(blog)
        expect(node.outerHTML).toBe '<div><h1 x-bind-text="title">Alpha</h1></div>'
        blog.title = "Beta"
        expect(node.outerHTML).toBe '<div><h1 x-bind-text="title">Beta</h1></div>'

    describe "component", ->
      it "replaces the bound element with a view based on the value of the bound property", ->
        Blog.property 'featuredItem'
        Post.property 'title'
        Comment.property 'body'

        tv.register 'Blog', content: ->
          @div =>
            @h1 "Featured Item"
            @div 'x-bind-component': "featuredItem"
        tv.register 'Post', content: -> @div id: 'post', 'x-bind-text': 'title'
        tv.register 'Comment', content: -> @div id: 'comment', 'x-bind-text': 'body'

        post = new Post(title: "Alpha")
        comment = new Comment(title: "Hello")
        blog = Blog.createAsRoot(featuredItem: post)

        element = tv.visualize(blog)
        expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div id="post" x-bind-text="title">Alpha</div></div>'

    describe "collection", ->
      it "populates the bound element with child views based on the contents of the bound collection", ->
        Blog.property 'posts'
        Post.property 'title'

        tv.register 'Blog', content: ->
          @div =>
            @h1 "My Posts:"
            @ol 'x-bind-collection': "posts"
        tv.Blog.register 'Post', content: ->
          @li 'x-bind-text': "title"

        post1 = new Post(title: "Alpha")
        post2 = new Post(title: "Bravo")
        post3 = new Post(title: "Charlie")
        blog = Blog.createAsRoot(posts: [post1, post2, post3])

        element = tv.visualize(blog)
        expect(element.outerHTML).toBe tv.buildHTML ->
          @div =>
            @h1 "My Posts:"
            @ol 'x-bind-collection': "posts", =>
              @li 'x-bind-text': "title", "Alpha"
              @li 'x-bind-text': "title", "Bravo"
              @li 'x-bind-text': "title", "Charlie"

        blog.posts.splice(1, 1, new Post(title: "Delta"), new Post(title: "Echo"))
        expect(element.outerHTML).toBe tv.buildHTML ->
          @div =>
            @h1 "My Posts:"
            @ol 'x-bind-collection': "posts", =>
              @li 'x-bind-text': "title", "Alpha"
              @li 'x-bind-text': "title", "Delta"
              @li 'x-bind-text': "title", "Echo"
              @li 'x-bind-text': "title", "Charlie"

        blog.posts = [new Post(title: "Foxtrot"), new Post(title: "Golf")]
        expect(element.outerHTML).toBe tv.buildHTML ->
          @div =>
            @h1 "My Posts:"
            @ol 'x-bind-collection': "posts", =>
              @li 'x-bind-text': "title", "Foxtrot"
              @li 'x-bind-text': "title", "Golf"
