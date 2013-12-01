{Model} = require 'telepath'
View = require '../src/view'

describe "View", ->
  [Blog, Post, Comment] = []

  beforeEach ->
    class Blog extends Model
    class Post extends Model
    class Comment extends Model

  describe "view construction", ->
    describe "via direct construction", ->
      it "builds an instance of the view if it matches the model, but otherwise throws an exception", ->
        class BlogView extends View
          @content: -> @div "Blog"

        view = new BlogView(new Blog)
        expect(view.element.outerHTML).toBe "<div>Blog</div>"

    describe "via ::buildView", ->
      it "builds an instance of the receiving view if it matches the model, but otherwise delegates to a matching immediate child or its parent", ->
        class PostView extends View
          @content: -> @div "Post"

        class CommentView extends View
          @content: -> @div "CommentView"

        class BlogView extends View
          @register PostView, CommentView
          @content: -> @div "Blog"

        expect(BlogView.buildView(new Blog).element.textContent).toBe "Blog"
        expect(BlogView.buildView(new Post).element.textContent).toBe "Post"
        expect(BlogView.CommentView.buildView(new Blog).element.textContent).toBe "Blog"
        expect(BlogView.CommentView.buildView(new Post).element.textContent).toBe "Post"
