createElement = require 'virtual-dom/create-element'
diff = require 'virtual-dom/diff'
patch = require 'virtual-dom/patch'

buildVirtualNode = require '../src/build-virtual-node'
observe = require '../src/observe'

describe "buildVirtualNode(name, [properties], children...)", ->
  it "can be passed observations as children", ->
    object = {animal: "cat", color: "red"}

    tree1 = buildVirtualNode('div', observe(object, 'animal'))
    element = createElement(tree1)
    expect(element.outerHTML).toBe "<div>cat</div>"

    # the element is updated automatically when the observation changes
    object.animal = "dog"
    waitsFor -> element.outerHTML is "<div>dog</div>"


    # can update with a new tree based on a different observation
    runs ->
      tree2 = buildVirtualNode 'div', observe object, 'color', (color) ->
        buildVirtualNode 'span', color

      patch(element, diff(tree1, tree2))
      expect(element.outerHTML).toBe "<div><span>red</span></div>"

      # unsubscribes from the old observation
      object.animal = "bird"

    waits 10

    runs ->
      expect(element.outerHTML).toBe "<div><span>red</span></div>"
      object.color = "blue"

    waitsFor ->
      element.outerHTML is "<div><span>blue</span></div>"
