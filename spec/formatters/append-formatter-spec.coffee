{Model} = require 'telepath'
television = require '../../src/television'

describe "AppendFormatter", ->
  [tv, Blog] = []

  beforeEach ->
    class Blog extends Model
    tv = television()

  it "appends the specified text to the property value", ->
    Blog.property 'title'
    tv.register
      name: 'BlogView'
      content: ->
        @div => @h1 'x-bind-text': "title | append ' World!'"

    blog = Blog.createAsRoot(title: "Hello")
    {element} = tv.buildView(blog)
    expect(element.outerHTML).toBe """<div><h1 x-bind-text="title | append ' World!'">Hello World!</h1></div>"""
    blog.title = "Goodbye"
    expect(element.outerHTML).toBe """<div><h1 x-bind-text="title | append ' World!'">Goodbye World!</h1></div>"""
