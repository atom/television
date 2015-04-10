Observation = require './observation'

module.exports = (object, properties, transform) ->
  if typeof properties is 'string'
    observeProperty(object, properties, transform)
  else
    observeProperties(object, properties, transform)

observeProperty = (object, property, transform) ->
  initialValue = transform?(object[property]) ? object[property]

  new Observation initialValue, (reportChange) ->
    Object.observe object, (changes) ->
      for change in changes when change.name is property
        newValue = transform?(object[property]) ? object[property]
        reportChange(newValue)
        break

observeProperties = (object, properties, transform) ->
  unless transform?
    throw new Error("When observing multiple properties, you must supply a function as the last argument")

  propertyValues = properties.map (property) -> object[property]
  initialValue = transform.apply(null, propertyValues)

  new Observation initialValue, (reportChange) ->
    Object.observe object, (changes) ->
      for change in changes when change.name in properties
        propertyValues = properties.map (property) -> object[property]
        newValue = transform.apply(null, propertyValues)
        reportChange(newValue)
        break
