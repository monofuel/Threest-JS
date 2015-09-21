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

exports._if = () ->
  this.else_ptr = -1
  this.then_ptr = -1

exports._else = () ->
  this.then_ptr = -1

exports._loop = () ->
  this.do_ptr = -1

global_dict =
  ":" :
    builtin : true
    function : () ->
      create_word()
  "ALERT" :
    builtin : true
    function : () ->
      alert(inter.pop())
  "DUP" :
    builtin : true
    function : () ->
      inter.push(inter.peek())
  "SWAP" :
    builtin : true
    function : () ->
      j = inter.pop()
      k = inter.pop()
      inter.push(j)
      inter.push(k)
  ">R" :
    builtin : true
    function : () ->
      inter.push_r(inter.pop())
  "R>" :
    builtin : true
    function : () ->
      inter.push(inter.pop_r())
  "I" :
    builtin : true
    function : () ->
      inter.push(inter.peek_r())
  "CR" :
    builtin : true
    function : () ->
      inter.output.push("\n")
  "+" :
    builtin : true
    function : () ->
      inter.push(inter.pop() + inter.pop())
  "-" :
    builtin : true
    function : () ->
      j = inter.pop()
      k = inter.pop()
      inter.push(k - j)
  "/" :
    builtin : true
    function : () ->
      j = inter.pop()
      k = inter.pop()
      inter.push(k / j)
  "*" :
    builtin : true
    function : () ->
      inter.push(inter.pop() * inter.pop())
  "<" :
    builtin : true
    function : () ->
      j = inter.pop()
      k = inter.pop()
      inter.push(k < j)
  ">" :
    builtin : true
    function : () ->
      j = inter.pop()
      k = inter.pop()
      inter.push(k > j)
  "=" :
    builtin : true
    function : () ->
      j = inter.pop()
      k = inter.pop()
      inter.push(k == j)
  "DROP" :
    builtin : true
    function : () ->
      inter.pop()
  "." :
    builtin : true
    function : () ->
      inter.output.push(inter.pop())
  "WORDS" :
    builtin : true
    function : () ->
      word_list = ""
      Object.keys(global_dict).forEach((word) ->
        word_list += word + " "
        )
      word_list += "IF "
      word_list += "ELSE "
      word_list += "THEN "
      word_list += "DO "
      word_list += "LOOP "
      word_list += "RECURSE"
      inter.output.push(word_list)
  "BYE" :
    builtin : true
    function : () ->
      inter.output.push("CYA")
      inter.exited = true
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
    if (list[index] == "IF")
      crate = new exports.crate(exports.types.if)
      crate.content = new exports._if()
      forward_index = index
      if_count = 0
      while forward_index < list.length
        forward_index++
        if(list[forward_index] == "IF")
          if_count++

        if(list[forward_index] == "THEN")
          if (if_count == 0)
            crate.content.then_ptr = forward_index - start_index
            break
          else
            if_count--

        if(list[forward_index] == "ELSE")
          if(if_count == 0)
            crate.content.else_ptr = forward_index - start_index
            #not really sure why we break
            #but the C++ version does this
            break

      if(forward_index == list.length)
        inter.output.push("found IF without matching THEN")

      word.function.push(crate)
      index++
      continue

    #else
    if (list[index] == "ELSE")
      crate = new exports.crate(exports.types.else)
      crate.content = new exports._else()
      forward_index = index
      if_count = 0
      while (forward_index < list.length)
        forward_index++
        if(list[forward_index] == "IF")
          if_count++

        if(list[forward_index] == "THEN")
          if (if_count == 0)
            crate.content.then_ptr = forward_index - start_index
            break
          else
            if_count--

      if(forward_index == list.length)
        inter.output.push("found ELSE without matching THEN")

      word.function.push(crate)
      index++
      continue

    #then
    if (list[index] == "THEN")
      crate = new exports.crate(exports.types.then)

      word.function.push(crate)
      index++
      continue

    #do
    if (list[index] == "DO")
      crate = new exports.crate(exports.types.do)

      word.function.push(crate)
      index++
      continue

    #loop
    if (list[index] == "LOOP")
      crate = new exports.crate(exports.types.loop)
      crate.content = new exports._loop()

      reverse_index = index
      loop_count = 0
      while (reverse_index > 0)
        reverse_index--
        if(list[reverse_index] == "LOOP")
          loop_count++

        if(list[reverse_index] == "DO")
          if (loop_count == 0)
            crate.content.do_ptr = reverse_index - start_index
          else
            loop_count--

      if(forward_index == list.length)
        inter.output.push("found LOOP without matching DO")

      word.function.push(crate)
      index++
      continue
    #float
    #array
    #object
    #string
    #bool
    #recursion
    if (list[index] == "RECURSE")
      crate = new exports.crate(exports.types.word)
      crate.content = word
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
