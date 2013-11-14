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
