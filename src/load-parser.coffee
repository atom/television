{existsSync, readFileSync} = require 'fs'
{join} = require 'path'
pegjs = require 'pegjs'

module.exports = (segments...) ->
  path = join(segments...)
  if existsSync(path + '.js')
    require path + '.js'
  else if existsSync(path + '.pegjs')
    pegjs.buildParser(readFileSync(path + '.pegjs', 'utf8'))
  else
    throw new Error("Can't find parser at path: #{path}")
