{
  _ = require('underscore')
  function flattenToString(v) {
    return _.flatten(v).join('')
  }
}

start = (constant / expression)*
constant = chars:(!expression .)+ { return flattenToString(chars) }
expression = '{{' expression:expressionContent '}}' { return {expression: expression} }
expressionContent = chars:(!'}}' .)* { return flattenToString(chars) }
