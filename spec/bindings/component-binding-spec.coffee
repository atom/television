{Model} = require 'telepath'
television = require '../../src/television'

describe "ComponentBinding", ->
  [tv, Blog, Post, Comment] = []

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

    {element} = tv.buildView(blog)
    expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div id="post" x-bind-text="title">Alpha</div></div>'

    blog.featuredItem = comment
    expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div id="comment" x-bind-text="body">Hello</div></div>'

    blog.featuredItem = null
    expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div x-bind-component="featuredItem">Placeholder</div></div>'

    post.title = "Beta"
    blog.featuredItem = post
    expect(element.outerHTML).toBe '<div><h1>Featured Item</h1><div id="post" x-bind-text="title">Beta</div></div>'
