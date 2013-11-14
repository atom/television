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
