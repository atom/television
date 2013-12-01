module.exports =
  id: 'append'

  read: (value, args...) ->
    if value?
      value.toString() + args.map((arg) -> arg.toString()).join('')
