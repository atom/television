{
  _ = require('underscore')
  function flattenToString(v) {
    return _.flatten(v).join('')
  }
}

start = _ property:identifier _ formatters:formatter* {
  return {property: property, formatters: formatters}
}

formatter = _ '|' _ name:identifier _ arguments:formatterArg* {
  return {name: name, arguments: arguments}
}

formatterArg = _ !'|' arg:(string / number / bareword) _ { return arg }

string = singleQuotedString / doubleQuotedString

singleQuotedString = "'" chars:(!"'" .)* "'" { return flattenToString(chars) }

doubleQuotedString = '"' chars:(!'"' .)* '"' { return flattenToString(chars) }

number = digits:([1-9.][0-9.]*) { return parseFloat(flattenToString(digits)) }

bareword = chars:(!" " .)+ { return flattenToString(chars) }

_ = " "*

identifier = chars:([a-zA-Z] [a-zA-Z0-9_]*) {
  return flattenToString(chars)
}
