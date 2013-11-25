{camelize} = require 'underscore.string'
Binding = require '../binding'

module.exports =
class StyleBinding extends Binding
  @id: /style-(.+)/

  constructor: ({id, @element, @reader}) ->
    @stylePropertyName = id.match(@constructor.id)[1]
    if /-in-percent$/.test(@stylePropertyName)
      @inPercent = true
      @stylePropertyName = @stylePropertyName.replace(/-in-percent/, '')
    else
      @inPercent = false
    @stylePropertyName = camelize(@stylePropertyName)
    @placeholderValue = @element.style[@stylePropertyName]

    @subscribe @reader, 'value', (value) =>
      if value?
        value += '%' if @inPercent
        @element.style[@stylePropertyName] = value
      else
        @element.style[@stylePropertyName] = @placeholderValue
