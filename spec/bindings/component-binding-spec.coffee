{Model} = require 'telepath'
television = require '../../src/television'

describe "ComponentBinding", ->
  [tv, Blog, Post, Comment, blog, post, comment] = []

  getModel = (view) -> view.model

  beforeEach ->
    class Blog extends Model
      @properties 'featuredItem', 'items'

    class Post extends Model
      @property 'title'

    class Comment extends Model
      @property 'body'

    post = new Post(title: "Alpha")
    comment = new Comment(body: "Hello")
    blog = Blog.createAsRoot(featuredItem: post, items: [post, comment])

    tv = television()

    tv.register
      name: 'BlogView'
      content: ->
        @div =>
          @h1 "Featured Item"
          @div 'x-bind-component': "featuredItem", "Placeholder"
      attached: -> @attachedCalled = true
      detached: -> @detachedCalled = true

    tv.register
      name: 'PostView'
      content: ->
        @div id: 'post', 'x-bind-text': 'title'
      attached: -> @attachedCalled = true
      detached: -> @detachedCalled = true

    tv.register
      name: 'CommentView'
      content: ->
        @div id: 'comment', 'x-bind-text': 'body'
      attached: -> @attachedCalled = true
      detached: -> @detachedCalled = true

  it "replaces the bound element with a view based on the value of the bound property", ->
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

  it "calls attached/detached hooks on the component views", ->
    view = tv.buildView(blog)
    document.body.appendChild(view.element)
    view.attachedToDocument()
    expect(view.attachedCalled).toBe true

    postView = view.viewForModel(post)
    expect(postView.attachedCalled).toBe true
    expect(postView.detachedCalled).toBeUndefined()

    blog.featuredItem = comment
    expect(postView.detachedCalled).toBe true
    commentView = view.viewForModel(comment)
    expect(commentView.attachedCalled).toBe true
    expect(commentView.detachedCalled).toBeUndefined()

    blog.featuredItem = null
    expect(commentView.detachedCalled).toBe true
