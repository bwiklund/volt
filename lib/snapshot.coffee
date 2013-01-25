# phantomjs static_renderer.coffee http://localhost:3000/#\!/usa

phantom.injectJs "jquery.min.js"

system = require("system")


class Route
  constructor: ->
    @cached = false
    @content = ""


class Crawler
  constructor: (@url,options={}) ->
    @options = $.extend {}, Crawler.defaults, options

    @routes = {}

    @client = require("webpage").create()
    @client.viewportSize = { width: @options.viewport_width, height: @options.viewport_height }
    @client.onConsoleMessage = (msg) -> console.log msg

    @client.open @url, (status) =>
      if status is "success"
        @wait_for_page()


  gather_hrefs: (str) ->
    links = $(str).find("a")
    that = this
    links.each => that.add_route $(this).attr("href")
    console.log @routes


  add_route: (href) ->
    @routes[href] = new Route


  wait_for_page: ->
    check_page = =>
      ready = @client.evaluate -> $('body').attr("data-status") is "ready"
      if ready then @read_page() else setTimeout check_page, @options.check_page_interval_ms
    check_page()


  read_page: ->
    setTimeout =>
      html = @client.evaluate ->
        # trim out some junk we don't want to keep
        $('script').remove() # no point saving scripts in static pages
        $("*").removeClass "preloading"
        $("*").removeClass "preloading"
        $("#trailer").remove()

        # and we're done
        $('html').html()

      @gather_hrefs html

      # phantom.exit()
    , @options.delay_before_snapshot


  @defaults: {
    check_page_interval_ms: 100 # how often to check if the page said it's ready
    delay_before_snapshot: 0    # how long to wait after that, in case there's animations
    viewport_width: 1024
    viewport_height: 768
  }





new Crawler "http://localhost:3000/#!/"


