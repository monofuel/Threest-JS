inter = require('./interpreter')

document.addEventListener('DOMContentLoaded', () ->
  threest = new Terminal()
  threest.setBackgroundColor("#002b36")
  threest.setTextColor("#586e75")

  threest.print("Welcome to Threest!")

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
