inter = require('./interpreter')

web_builtin = [
  ": PEEK DUP . ;"
  ": FIB ( n -- n' ) DUP 1 = IF DROP 1 ELSE DUP 2 = IF DROP 1 ELSE 1 - DUP 1 - RECURSE SWAP RECURSE + THEN THEN ;"
]
document.addEventListener('DOMContentLoaded', () ->
  threest = new Terminal()
  threest.setBackgroundColor("#002b36")
  threest.setTextColor("#586e75")

  threest.print("Welcome to Threest!")

  web_builtin.forEach((word) ->
    inter.parse_line(word)
    )

  repl = () ->
    threest.input(">",(input) ->
      inter.parse_line(input)
      inter.output.forEach((o) ->
        threest.print(o)
      )
      if (!inter.exited)
        repl()

    )

  repl()

  termDiv.appendChild(threest.html)

,false)
