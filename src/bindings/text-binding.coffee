Binding = require '../binding'

module.exports =
class TextBinding extends Binding
  @type: 'text'

  constructor: ({@element, @reader}) ->
    @subscribe @reader, 'value', (value) =>
      @element.textContent = value
