Factory = require '../src/factory'

describe "Factory", ->
  factory = null

  class Blog
  class Post
  class Comment

  beforeEach ->
    factory = new Factory(name: "Blog", content: "<div>Blog</div>")
    factory.register("Post", content: "<div>Post</div>")
    factory.register("Comment", content: "<div>Comment</div>")

  describe "factory selection", ->
    describe "when the receiving factory can build a view for the given model", ->
      it "constructs a view for itself", ->
        expect(factory.build(new Blog).outerHTML).toBe "<div>Blog</div>"

    describe "when the receiving factory cannot build a view for the given model", ->
      describe "when it has a subfactory that can build a view for the given model", ->
        it "delegates construction to the subfactory", ->
          expect(factory.build(new Post).outerHTML).toBe "<div>Post</div>"
          expect(factory.build(new Comment).outerHTML).toBe "<div>Comment</div>"

      describe "when it does *not* have a subfactory that can build a view for the the model model", ->
        describe "when it has a parent factory", ->
          it "delegates the call to its parent", ->
            expect(factory.Post.build(new Comment).outerHTML).toBe "<div>Comment</div>"

        describe "when it is the root factory", ->
          it "returns undefined", ->
            class Favorite
            expect(factory.build(new Favorite)).toBeUndefined()
