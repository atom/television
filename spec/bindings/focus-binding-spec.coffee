{Model} = require 'telepath'
television = require '../../src/television'

describe "FocusBinding", ->
  [tv, Container, child, child1, child2, element] = []

  beforeEach ->
    class Parent extends Model
      @property 'children', []

    class Child extends Model
      @property 'focused', false

    tv = television()
    tv.register
      name: 'ParentView'
      content: -> @ol 'x-bind-collection': 'children'

    tv.register
      name: 'ChildView'
      content: -> @input 'x-bind-focus': "focused"

    child1 = new Child
    child2 = new Child
    parent = Parent.createAsRoot(children: [child1, child2])
    {element} = tv.viewForModel(parent)

  it "focuses/blurs the bound element when the property changes", ->
    expect(document.activeElement).not.toBe element.firstChild
    expect(document.activeElement).not.toBe element.lastChild

    child1.focused = true
    expect(document.activeElement).toBe(element.firstChild)

    child1.focused = false
    expect(document.activeElement).not.toBe element.firstChild
    expect(document.activeElement).not.toBe element.lastChild

    child2.focused = true
    expect(document.activeElement).toBe(element.lastChild)

  it "sets the property when the bound element is focused/blurred", ->
    expect(child1.focused).toBe false
    expect(child2.focused).toBe false

    element.firstChild.focus()
    expect(child1.focused).toBe true
    expect(child2.focused).toBe false

    element.firstChild.blur()
    expect(child1.focused).toBe false
    expect(child2.focused).toBe false

    element.lastChild.focus()
    expect(child1.focused).toBe false
    expect(child2.focused).toBe true

    element.firstChild.focus()
    expect(child1.focused).toBe true
    expect(child2.focused).toBe false
