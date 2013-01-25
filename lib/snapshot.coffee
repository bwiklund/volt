# phantomjs static_renderer.coffee http://localhost:3000/#\!/usa

phantom.injectJs "jquery.min.js"

system = require("system")

class Crawler
  constructor: (@url,@options={}) ->

    @page = require("webpage").create()
    @page.viewportSize = { width: 1024, height: 718 }
    @page.onConsoleMessage = (msg) -> console.log msg

    @page.open @url, (status) =>
      if status is "success"
        @wait_for_page()


  wait_for_page: ->
    check_page = =>
      ready = @page.evaluate -> $('body').attr("data-status") is "ready"
      if ready then @read_page() else setTimeout check_page, 100
    check_page()


  read_page: ->
    setTimeout =>
      console.log @page.evaluate ->
        # trim out some junk we don't want to keep
        $('script').remove() # no point saving scripts in static pages
        $("*").removeClass "preloading"
        $("*").removeClass "preloading"
        $("#trailer").remove()

        # and we're done
        $('html').html()
      phantom.exit()
    ,0#1000





new Crawler "http://localhost:3000/#!/"


