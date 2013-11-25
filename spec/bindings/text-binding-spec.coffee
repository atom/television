{Model} = require 'telepath'
television = require '../../src/television'

describe "TextBinding", ->
  [tv, Blog] = []

  beforeEach ->
    class Blog extends Model
    tv = television()

  describe "when bound via an x-bind-text attribute", ->
    it "replaces the bound element's text content with the value of the bound property", ->
      Blog.property 'title'
      tv.register
        name: 'BlogView'
        content: ->
          @div => @h1 'x-bind-text': "title"

      blog = Blog.createAsRoot(title: "Alpha")
      {element} = tv.viewForModel(blog)
      expect(element.outerHTML).toBe '<div><h1 x-bind-text="title">Alpha</h1></div>'
      blog.title = "Beta"
      expect(element.outerHTML).toBe '<div><h1 x-bind-text="title">Beta</h1></div>'

  describe "when bound via a template", ->
    it "replaces the bound element's text content with the template's content", ->
      Blog.properties 'title', 'subtitle'
      tv.register
        name: 'BlogView'
        content: ->
          @div => @h1 "{{title}} – {{subtitle}}!"

      blog = Blog.createAsRoot(title: "Alpha", subtitle: "Comes before Beta")
      {element} = tv.viewForModel(blog)
      expect(element.outerHTML).toBe '<div><h1>Alpha – Comes before Beta!</h1></div>'

      blog.title = "Beta"
      expect(element.outerHTML).toBe '<div><h1>Beta – Comes before Beta!</h1></div>'

      blog.subtitle = "Comes after Alpha"
      expect(element.outerHTML).toBe '<div><h1>Beta – Comes after Alpha!</h1></div>'
