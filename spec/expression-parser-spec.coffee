loadParser = require '../src/load-parser'
ExpressionParser = loadParser(__dirname, '..', 'src', 'expression-parser')

describe "ExpressionParser", ->
  it "parses single property names", ->
    expect(ExpressionParser.parse("title")).toEqual {
      property: 'title'
      formatters: []
    }

  it "parses property names with formatters", ->
    expect(ExpressionParser.parse("title | titleize | truncate")).toEqual {
      property: 'title'
      formatters: [
        {id: 'titleize', args: []}
        {id: 'truncate', args: []}
      ]
    }

  it "parses property names with formatters taking arguments", ->
    expect(ExpressionParser.parse("""title | append ' Foo ' "Bar Baz" | replace foo bar 2""")).toEqual {
      property: 'title'
      formatters: [
        {id: 'append', args: [" Foo ", "Bar Baz"]}
        {id: 'replace', args: ["foo", "bar", 2]}
      ]
    }
