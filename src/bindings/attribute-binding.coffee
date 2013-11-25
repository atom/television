Binding = require '../binding'

module.exports =
class AttributeBinding extends Binding
  @id: /attribute-(.+)/

  constructor: ({id, @element, @reader}) ->
    @attributeName = id.match(@constructor.id)[1]
    @placeholderValue = @element.getAttribute(@attributeName)
    @subscribe @reader, 'value', (value) =>
      if value ?= @placeholderValue
        @element.setAttribute(@attributeName, value)
      else
        @element.removeAttribute(@attributeName)
