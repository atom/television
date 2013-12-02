{Model} = require 'telepath'
television = require '../../src/television'

describe "ComponentBinding", ->
  [tv, Blog, Post, Comment] = []

  getModel = (view) -> view.model

  beforeEach ->
    class Blog extends Model
    class Post extends Model
    class Comment extends Model
    tv = television()

  it "replaces the bound element with a view based on the value of the bound property", ->
    Blog.properties 'featuredItem', 'items'
    Post.property 'title'
    Comment.property 'body'

    tv.register
      name: 'BlogView'
      content: ->
        @div =>
          @h1 "Featured Item"
          @div 'x-bind-component': "featuredItem", "Placeholder"

    tv.register
      name: 'PostView'
      content: ->
        @div id: 'post', 'x-bind-text': 'title'

    tv.register
      name: 'CommentView'
      content: ->
        @div id: 'comment', 'x-bind-text': 'body'

    post = new Post(title: "Alpha")
    comment = new Comment(body: "Hello")
    blog = Blog.createAsRoot(featuredItem: post, items: [post, comment])

    view = tv.buildView(blog)
    {element} = view
    expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div id="post" x-bind-text="title">Alpha</div></div>'
    expect(view.viewsForModel(post).map(getModel)).toEqual [post]

    blog.featuredItem = comment
    expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div id="comment" x-bind-text="body">Hello</div></div>'
    expect(view.viewsForModel(post)).toEqual []
    expect(view.viewsForModel(comment).map(getModel)).toEqual [comment]

    blog.featuredItem = null
    expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div x-bind-component="featuredItem">Placeholder</div></div>'
    expect(view.viewsForModel(post)).toEqual []
    expect(view.viewsForModel(comment)).toEqual []

    post.title = "Beta"
    blog.featuredItem = post
    expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div id="post" x-bind-text="title">Beta</div></div>'
    expect(view.viewsForModel(post).map(getModel)).toEqual [post]
