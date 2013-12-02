{Model} = require 'telepath'
television = require '../../src/television'

describe "CollectionBinding", ->
  [tv, Blog, Post, blog, post1, post2, post3] = []

  getModel = (view) -> view.model

  beforeEach ->
    class Blog extends Model
      @property 'posts'

    class Post extends Model
      @property 'title'

    post1 = new Post(title: "Alpha")
    post2 = new Post(title: "Bravo")
    post3 = new Post(title: "Charlie")
    blog = Blog.createAsRoot(posts: [post1, post2, post3])

    tv = television()

    tv.register
      name: 'BlogView'
      content: ->
        @div =>
          @h1 "My Posts:"
          @ol 'x-bind-collection': "posts"

    tv.BlogView.register
      name: 'PostView',
      content: ->
        @li 'x-bind-text': "title"
      attached: -> @attachedCalled = true
      detached: -> @detachedCalled = true

  it "populates the bound element with child views based on the contents of the bound collection", ->
    view = tv.buildView(blog)
    {element} = view
    expect(element.outerHTML).toBe tv.buildHTML ->
      @div =>
        @h1 "My Posts:"
        @ol 'x-bind-collection': "posts", =>
          @li 'x-bind-text': "title", "Alpha"
          @li 'x-bind-text': "title", "Bravo"
          @li 'x-bind-text': "title", "Charlie"
    expect(view.viewsForModel(post1).map(getModel)).toEqual [post1]
    expect(view.viewsForModel(post2).map(getModel)).toEqual [post2]
    expect(view.viewsForModel(post3).map(getModel)).toEqual [post3]

    post4 = new Post(title: "Delta")
    post5 = new Post(title: "Echo")
    blog.posts.splice(1, 1, post4, post5)
    expect(element.outerHTML).toBe tv.buildHTML ->
      @div =>
        @h1 "My Posts:"
        @ol 'x-bind-collection': "posts", =>
          @li 'x-bind-text': "title", "Alpha"
          @li 'x-bind-text': "title", "Delta"
          @li 'x-bind-text': "title", "Echo"
          @li 'x-bind-text': "title", "Charlie"
    expect(view.viewsForModel(post1).map(getModel)).toEqual [post1]
    expect(view.viewsForModel(post2).map(getModel)).toEqual []
    expect(view.viewsForModel(post3).map(getModel)).toEqual [post3]
    expect(view.viewsForModel(post4).map(getModel)).toEqual [post4]
    expect(view.viewsForModel(post5).map(getModel)).toEqual [post5]
    expect(view.viewForModel(post5).model).toBe post5

    post6 = new Post(title: "Foxtrot")
    post7 = new Post(title: "Golf")
    blog.posts = [post6, post7]
    expect(element.outerHTML).toBe tv.buildHTML ->
      @div =>
        @h1 "My Posts:"
        @ol 'x-bind-collection': "posts", =>
          @li 'x-bind-text': "title", "Foxtrot"
          @li 'x-bind-text': "title", "Golf"

    expect(view.viewsForModel(post1)).toEqual []
    expect(view.viewsForModel(post2)).toEqual []
    expect(view.viewsForModel(post3)).toEqual []
    expect(view.viewsForModel(post4)).toEqual []
    expect(view.viewsForModel(post5)).toEqual []
    expect(view.viewsForModel(post6).map(getModel)).toEqual [post6]
    expect(view.viewsForModel(post7).map(getModel)).toEqual [post7]

  it "calls attached/detached hooks on the child views", ->
    view = tv.buildView(blog)
    {element} = view
    document.body.appendChild(element)
    view.attachedToDocument()

    postView1 = view.viewForModel(post1)
    postView2 = view.viewForModel(post2)
    postView3 = view.viewForModel(post3)
    expect(postView1.attachedCalled).toBe true
    expect(postView2.attachedCalled).toBe true
    expect(postView3.attachedCalled).toBe true

    post4 = new Post(title: "Delta")
    post5 = new Post(title: "Echo")
    blog.posts.splice(1, 1, post4, post5)
    expect(postView2.detachedCalled).toBe true
    postView4 = view.viewForModel(post4)
    postView5 = view.viewForModel(post5)
    expect(postView4.attachedCalled).toBe true
    expect(postView5.attachedCalled).toBe true

    post6 = new Post(title: "Foxtrot")
    post7 = new Post(title: "Golf")
    blog.posts = [post6, post7]
    expect(postView1.detachedCalled).toBe true
    expect(postView3.detachedCalled).toBe true
    postView6 = view.viewForModel(post6)
    postView7 = view.viewForModel(post7)
    expect(postView6.attachedCalled).toBe true
    expect(postView7.attachedCalled).toBe true
