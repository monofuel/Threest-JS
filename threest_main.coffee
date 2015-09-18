inter = require('./interpreter')
readline = require('readline')

init = () ->
  
  #TODO: parse arguments

  #TODO add builtin commands

  rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal:true
  })  

  rl.setPrompt('>')
  rl.on('line',inter.parse_line)
  rl.prompt(true);

init()
