ViewFactory = require './view-factory'
View = require './view'
Binding = require './binding'

module.exports = -> new ViewFactory
module.exports.View = View
module.exports.Binding = Binding
