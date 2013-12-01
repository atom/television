{Model} = require 'telepath'
television = require '../../src/television'

describe "StyleBinding", ->
  [tv, Blog] = []

  beforeEach ->
    class Blog extends Model
    tv = television()

  it "assigns the named style attribute to the value of the bound property", ->
    Blog.properties 'width', 'height', 'backgroundColor'
    tv.register
      name: 'BlogView'
      content: ->
        @div {
          'x-bind-style-width': "width | append %"
          'x-bind-style-height': "height"
          'x-bind-style-background-color': "backgroundColor"
          style: "width: 50%"
        }

    blog = Blog.createAsRoot(width: 80, height: 100, backgroundColor: "red")
    {element} = tv.viewForModel(blog)
    expect(element.style.width).toBe "80%"
    expect(element.style.height).toBe "100px"
    expect(element.style.backgroundColor).toBe "red"

    blog.width = 75
    blog.backgroundColor = "blue"
    expect(element.style.width).toBe "75%"
    expect(element.style.backgroundColor).toBe "blue"

    blog.width = null
    blog.backgroundColor = null
    expect(element.style.width).toBe "50%"
    expect(element.style.backgroundColor).toBe ""
