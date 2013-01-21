# phantomjs static_renderer.coffee http://localhost:3000/#\!/usa

system = require("system")


url = system.args[1] or ""
if url.length > 0
  page = require("webpage").create()
  page.viewportSize = { width: 1024, height: 718 }
  page.onConsoleMessage = (msg) ->
    console.log msg
  page.open url, (status) ->
    if status is "success"
      delay = undefined
      checker = (->
        ready = page.evaluate(->
          if $('body').attr("data-status") is "ready"
            true
        )
        if ready
          clearTimeout delay
          # give the page a grace period now, for transition animations to stop
          # otherwise those will also be frozen in place
          
          setTimeout ->
            console.log page.evaluate ->
              # trim out some junk we don't want to keep
              $('script').remove() # no point saving scripts in static pages
              $("*").removeClass "preloading"
              $("*").removeClass "preloading"
              $("#trailer").remove()

              # and we're done
              $('html').html()
            phantom.exit()
          ,1000
      )
      delay = setInterval(checker, 100)

