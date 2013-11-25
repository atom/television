{readFileSync} = require 'fs'
{join} = require 'path'

PEG = require 'pegjs'
parser = PEG.buildParser(readFileSync(join(__dirname, '..', 'src', "expression-parser.pegjs"), 'utf8'))

describe "ExpressionParser", ->
  it "parses single property names", ->
    expect(parser.parse("title")).toEqual {
      property: 'title'
      formatters: []
    }

  it "parses property names with formatters", ->
    expect(parser.parse("title | titleize | truncate")).toEqual {
      property: 'title'
      formatters: [
        {name: 'titleize', arguments: []}
        {name: 'truncate', arguments: []}
      ]
    }

  it "parses property names with formatters taking arguments", ->
    expect(parser.parse("""title | append ' Foo ' "Bar Baz" | replace foo bar 2""")).toEqual {
      property: 'title'
      formatters: [
        {name: 'append', arguments: [" Foo ", "Bar Baz"]}
        {name: 'replace', arguments: ["foo", "bar", 2]}
      ]
    }
