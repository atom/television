Binding = require '../binding'

module.exports =
class TextBinding extends Binding
  @id: 'text'

  constructor: ({@element, @reader}) ->
    @subscribe @reader, 'value', (value) =>
      @element.textContent = value
