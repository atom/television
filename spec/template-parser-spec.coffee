TemplateParser = require '../src/template-parser'

describe "TemplateParser", ->
  it "breaks the template up into an array of constant strings and expressions", ->
    expect(TemplateParser.parse("Hello {{adjective}} {{noun}}!")).toEqual [
      "Hello ", {expression: "adjective"}, " ", {expression: "noun"}, "!"
    ]
