observe = require '../src/observe'

describe "observe(...)", ->
  describe "when called with an object and a property name", ->
    it "returns an observation based on the property's value", ->
      object = {a: 1}
      observation = observe(object, 'a')
      changeCount = 0
      observation.onChange -> changeCount++

      expect(observation.getValue()).toBe 1

      object.a = 2

      waitsFor ->
        changeCount is 1

      runs ->
        expect(observation.getValue()).toBe 2
        object.a = 3

      waitsFor ->
        changeCount is 2

      runs ->
        expect(observation.getValue()).toBe 3

    describe "when the last argument is a transform function", ->
      it "maps the transform function over the property observation's value", ->
        object = {a: 1}
        observation = observe(object, 'a', (v) -> v + 100)
        changeCount = 0
        observation.onChange -> changeCount++

        expect(observation.getValue()).toBe 101

        object.a = 2

        waitsFor ->
          changeCount is 1

        runs ->
          expect(observation.getValue()).toBe 102
          object.a = 3

        waitsFor ->
          changeCount is 2

        runs ->
          expect(observation.getValue()).toBe 103

  describe "when called with an object, multiple property names, and a function", ->
    it "returns a composite observation based on applying the function to all the property values", ->
      object = {a: 1, b: 2, c: 3}
      observation = observe(object, ['a', 'b', 'c'], ((a, b, c) -> a + b + c))
      changeCount = 0
      observation.onChange -> changeCount++

      expect(observation.getValue()).toBe 6

      object.a = 2

      waitsFor ->
        changeCount is 1

      runs ->
        expect(observation.getValue()).toBe 7
        object.b = 3

      waitsFor ->
        changeCount is 2

      runs ->
        expect(observation.getValue()).toBe 8
