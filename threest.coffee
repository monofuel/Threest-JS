inter = require('./interpreter')

exports.types =
  word : 0
  if : 1
  else : 2
  then : 3
  do : 4
  loop : 5
  int : 6
  float : 7
  array : 8
  object : 9
  string : 10
  bool : 11

#if builtin is true, function will be a JS function
#otherwise, it have a list of crates

exports.word = (builtin,content) ->
  this.builtin = builtin
  this.function = content


exports.crate = (type,content) ->
  this.type = type
  this.content = content

exports._if =
  else_ptr : 0
  then_ptr : 0

exports._else =
  then_ptr : 0

exports._loop =
  do_ptr : 0

global_dict =
  ":" :
    builtin : true
    function : () ->
      create_word()
  "+" :
    builtin : true
    function : () ->
      inter.push(inter.pop() + inter.pop())
  "*" :
    builtin : true
    function : () ->
      inter.push(inter.pop() * inter.pop())
  "." :
    builtin : true
    function : () ->
      console.log(inter.pop())
  "BYE" :
    builtin : true
    function : () ->
      console.log("CYA")
      process.exit(0)

exports.get_word = (word) ->
  return global_dict[word]

create_word = () ->
  list = inter.get_line()
  index = inter.get_current_word()
  start_index = index + 3
  word_name = list[++index]
  word = new exports.word(false)
  word.function = new Array()

  index++
  while (list[index] != ';')
    #int
    if (!isNaN(parseInt(list[index])))
      crate = new exports.crate(exports.types.int, parseInt(list[index]))
      word.function.push(crate)
      index++
      continue

    #if


    #else
    #then
    #do
    #loop
    #float
    #array
    #object
    #string
    #bool
    #recursion
    if (list[index] == "RECURSE")
      crate = new exports.crate(exports.types.word,exports.word)
      word.function.push(crate)
      index++
      continue

    #word
    if (exports.get_word(list[index]) != undefined)
      crate = new exports.crate(exports.types.word)
      crate.content = exports.get_word(list[index])
      word.function.push(crate)
      index++
      continue

    index++


  #console.log(word)
  global_dict[word_name] = word
  inter.set_current_word(index)
