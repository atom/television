{Model, Document} = require 'telepath'
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
      tv.register(name: "Blog", content: "<div>Blog</div>")
      tv.Blog.register(name: "Post", content: "<div>Post</div>")
      tv.Blog.register(name: "Comment", content: "<div>Comment</div>")

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
        tv.Blog.content = jasmine.createSpy("template.content").andReturn "<div></div>"
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

  describe "caching", ->
    it "recycles existing views if they aren't currently attached to some other view", ->
      tv.register "Blog", content: "<div x-bind-text='title'></div>"
      Blog.property 'title'

      doc = Document.create()
      blog = doc.set('blog', new Blog(title: "Alpha"))

      expect(blog.state.getSubscriptionCount('changed')).toBe 0

      blogElement1 = tv.visualize(blog)

      expect(blog.state.getSubscriptionCount('changed')).toBe 1

      expect(tv.visualize(blog)).toBe blogElement1

      parentElement = window.document.createElement("div")
      parentElement.appendChild(blogElement1)

      blogElement2 = tv.visualize(blog)
      expect(blogElement2).not.toBe blogElement1
      expect(tv.visualize(blog)).toBe blogElement2

      parentElement.appendChild(blogElement2)
      expect(tv.visualize(blog)).not.toBe blogElement1
      expect(tv.visualize(blog)).not.toBe blogElement2

      parentElement.removeChild(blogElement1)
      expect(tv.visualize(blog)).toBe blogElement1

      # clear out cache when the model is detached
      doc.remove('blog')
      expect(tv.Blog.getCachedElement(blog)).toBeUndefined()
      expect(blog.state.getSubscriptionCount()).toBe 0
