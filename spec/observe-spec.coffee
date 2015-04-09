observe = require '../src/observe'

describe "observe", ->
  it "can observe single properties on objects", ->
    object = {a: 1}
    observation = observe(object, 'a')
    mappedObservation = observation.map (v) -> v + 100

    observation.changeCount = 0
    mappedObservation.changeCount = 0
    observation.onChange -> observation.changeCount++
    mappedObservation.onChange -> mappedObservation.changeCount++

    expect(observation.getValue()).toBe 1
    expect(mappedObservation.getValue()).toBe 101

    object.a = 2
    waitsFor ->
      observation.changeCount is 1 and mappedObservation.changeCount is 1

    runs ->
      expect(observation.getValue()).toBe 2
      expect(mappedObservation.getValue()).toBe 102

      object.a = 3

    waitsFor ->
      observation.changeCount is 2 and mappedObservation.changeCount is 2

    runs ->
      expect(observation.getValue()).toBe 3
      expect(mappedObservation.getValue()).toBe 103
