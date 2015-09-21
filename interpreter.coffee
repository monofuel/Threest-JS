threest = require('./threest')

stack = new Array()
return_stack = new Array()

output = new Array()

exports.output = output

return_lines = []

line_list = ""
current_word = 0

bail_out = false
exited = false
exports.exited = exited

create_word = () ->
  current_word++

push = (a) ->
  stack.push(a)

pop = () ->
  if (stack.length == 0)
    console.log("STACK UNDERFLOW")
  return stack.pop()

peek = () ->
  if (stack.length == 0)
    console.log("STACK UNDERFLOW")
  return stack[stack.length-1]

push_r = (a) ->
  return_stack.push(a)

pop_r = () ->
  if (return_stack.length == 0)
    console.log("STACK UNDERFLOW")
  return return_stack.pop()

peek_r = () ->
  if (return_stack.length == 0)
    console.log("STACK UNDERFLOW")
  return return_stack[return_stack.length-1]

exports.push = push
exports.pop = pop
exports.peek = peek
exports.push_r = push_r
exports.pop_r = pop_r
exports.peek_r = peek_r

run_word = (word) ->

  console.log(word)

  if (bail_out)
    return

  if (return_lines.length > 20)
    console.log("depth limit exceeded, bailing out")
    bail_out = true
    return

  index = 0
  limit = 0
  choice = 0
  element = {}
  switch word.type
    when threest.types.do
      index = pop()
      limit = pop()
      push_r(limit)
      push_r(index)

    when threest.types.loop
     index = pop_r()
     limit = pop_r()
     index++

     if (index >= 2000)
       console.log("loop limit exceeded, bailing out")
       bail_out = true
       return
     if (limit == index)
       break
     else
       current_word = word.content.do_ptr + 1
       push_r(limit)
       push_r(index)
    when threest.types.if
      #pop the value off the stack and see if it's true.
			#if it is, continue execution. otherwise, jump to else.
			#if else doesn't exist, jump to then.
			#the compiler assumes if else is -1, else does not exist
			#since negative values make no sense for our word array
      choice = pop()
      if (!choice)
        if (word.content.else_ptr == -1)
          current_word = word.content.then_ptr + 1
        else
          current_word = word.content.else_ptr + 1

    when threest.types.else
      current_word = word.content.then_ptr + 1
    when threest.types.then
      #WE AIN'T DOIN SHIT
      return
    when threest.types.word
      #step through the word
      content = word.content
      if (content.builtin)
        #execute javascript function
        content.function()
      else
        #otherwise iterate over sub-words
        old_current_word = current_word
        current_word = 0
        return_lines.push(current_line)
        current_line = content.function

        while (current_word < current_line.length)
          run_word(current_line[current_word])
          current_word++

        #restore things
        current_word = old_current_word
        current_line = return_lines.pop()

    when threest.types.int
      push(word.content)

exports.get_line = () ->
  return current_line

exports.get_current_word = () ->
  return current_word

exports.set_current_word = (index) ->
  current_word = index

exports.parse_line = (line) ->
  bail_out = false
  output = new Array()
  exports.output = output

  if (line == "")
    return

  line_list = line.split(" ")

  exports.get_line = () ->
    return line_list

  current_word = 0
  while current_word < line_list.length
    word = line_list[current_word]

    #skip comments
    if (word == '(')
      while (true)
        if (line_list[++current_word] >= line_list.length)
          output.push("unfinished comment: " + line)
          return;
        if (line_list[current_word].endsWith(')'))
          break;

    #skip whitespace and stuff
    if (word == ' ' || word == '\n')
      #skip
    else if (!isNaN(parseInt(word)))
      crate = new threest.crate(threest.types.int)
      crate.content = parseInt(word)
      run_word(crate)
    else if (threest.get_word(word) != undefined)
      crate = new threest.crate(threest.types.word)
      crate.content = threest.get_word(word)
      run_word(crate)
    else
      output.push("word not found")

    current_word++

  output.push("OK.")
