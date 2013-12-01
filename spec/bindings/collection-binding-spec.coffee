{Model} = require 'telepath'
television = require '../../src/television'

describe "CollectionBinding", ->
  [tv, Blog, Post, Comment] = []

  beforeEach ->
    class Blog extends Model
    class Post extends Model
    class Comment extends Model
    tv = television()

  it "populates the bound element with child views based on the contents of the bound collection", ->
    Blog.property 'posts'
    Post.property 'title'

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

    post1 = new Post(title: "Alpha")
    post2 = new Post(title: "Bravo")
    post3 = new Post(title: "Charlie")
    blog = Blog.createAsRoot(posts: [post1, post2, post3])

    view = tv.buildView(blog)
    {element} = view
    expect(element.outerHTML).toBe tv.buildHTML ->
      @div =>
        @h1 "My Posts:"
        @ol 'x-bind-collection': "posts", =>
          @li 'x-bind-text': "title", "Alpha"
          @li 'x-bind-text': "title", "Bravo"
          @li 'x-bind-text': "title", "Charlie"
    expect(view.viewsForModel(post1).length).toBe 1
    expect(view.viewForModel(post1).model).toBe post1
    expect(view.viewsForModel(post2).length).toBe 1
    expect(view.viewForModel(post2).model).toBe post2
    expect(view.viewsForModel(post3).length).toBe 1
    expect(view.viewForModel(post3).model).toBe post3

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
    expect(view.viewsForModel(post1).length).toBe 1
    expect(view.viewForModel(post1).model).toBe post1
    expect(view.viewsForModel(post2).length).toBe 0
    expect(view.viewsForModel(post3).length).toBe 1
    expect(view.viewForModel(post3).model).toBe post3
    expect(view.viewsForModel(post4).length).toBe 1
    expect(view.viewForModel(post4).model).toBe post4
    expect(view.viewsForModel(post5).length).toBe 1
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

    expect(view.viewsForModel(post1).length).toBe 0
    expect(view.viewsForModel(post2).length).toBe 0
    expect(view.viewsForModel(post3).length).toBe 0
    expect(view.viewsForModel(post4).length).toBe 0
    expect(view.viewsForModel(post5).length).toBe 0
    expect(view.viewsForModel(post5).length).toBe 0
    expect(view.viewsForModel(post6).length).toBe 1
    expect(view.viewForModel(post6).model).toBe post6
    expect(view.viewsForModel(post7).length).toBe 1
    expect(view.viewForModel(post7).model).toBe post7
