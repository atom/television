Binding = require '../binding'

module.exports =
class AttributeBinding extends Binding
  @type: /attribute-(.+)/

  constructor: ({type, @element, @reader}) ->
    @attributeName = type.match(@constructor.type)[1]
    @placeholderValue = @element.getAttribute(@attributeName)
    @subscribe @reader, 'value', (value) =>
      if value ?= @placeholderValue
        @element.setAttribute(@attributeName, value)
      else
        @element.removeAttribute(@attributeName)
