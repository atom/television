{Model} = require 'telepath'
television = require '../../src/television'

describe "AttributeBinding", ->
  [tv, User] = []

  beforeEach ->
    class User extends Model
      @property 'avatarUrl'

    tv = television()

  it "assigns the specified attribute on the element with the value of the bound property", ->
    tv.register
      name: 'UserView'
      content: -> @img 'x-bind-attribute-src': "avatarUrl", src: "placeholder.png"

    user = User.createAsRoot(avatarUrl: "/images/john.png")
    {element} = tv.viewForModel(user)
    expect(element.outerHTML).toBe '<img x-bind-attribute-src="avatarUrl" src="/images/john.png" />'
    user.avatarUrl = "/images/jane.png"
    expect(element.outerHTML).toBe '<img x-bind-attribute-src="avatarUrl" src="/images/jane.png" />'
    user.avatarUrl = null
    expect(element.outerHTML).toBe '<img x-bind-attribute-src="avatarUrl" src="placeholder.png" />'

  it "removes the attribute entirely if there is no placeholder value and the bound value is null", ->
    tv.register
      name: 'UserView'
      content: -> @img 'x-bind-attribute-src': "avatarUrl"

    user = User.createAsRoot(avatarUrl: "/images/john.png")
    {element} = tv.viewForModel(user)
    expect(element.outerHTML).toBe '<img x-bind-attribute-src="avatarUrl" src="/images/john.png" />'
    user.avatarUrl = null
    expect(element.outerHTML).toBe '<img x-bind-attribute-src="avatarUrl" />'
