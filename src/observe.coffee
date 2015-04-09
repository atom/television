Observation = require './observation'

module.exports =
(object, propertyName) ->
  new Observation (setValue) ->
    setValue(object[propertyName])
    Object.observe object, (changes) ->
      for change in changes when change.name is propertyName
        setValue(object[propertyName])
        break
