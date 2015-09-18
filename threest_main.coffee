inter = require('./interpreter')
readline = require('readline')

init = () ->

  #TODO: parse arguments

  #terminal: false works good on windows
  #terminal: true for any other system.

  rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal:false
  })

  handle_input = (line) ->
    inter.parse_line(line)
    rl.prompt(true)

  rl.setPrompt('>')
  rl.on('line',handle_input)
  rl.prompt(true);

init()
