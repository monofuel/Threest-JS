app = require('app')
browser_window = require('browser-window')
require('crash-reporter').start()

main_window = null

app.on('window-all-closed',() ->
  app.quit()
  )


app.on('ready',() ->
  main_window = new browser_window({width: 1800, height: 600})

  main_window.loadUrl('file://' + __dirname + '/index.html')

  main_window.openDevTools()

  main_window.on('closed', () =>
    main_window = null
    )

  )
