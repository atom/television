module.exports =
  id: 'append'

  read: (value, args...) ->
    value.toString() + args.map((arg) -> arg.toString()).join('')
