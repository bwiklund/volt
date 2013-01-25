# phantomjs static_renderer.coffee http://localhost:3000/#\!/usa

phantom.injectJs "jquery.min.js"

system = require("system")


class Route
  constructor: (@hash) ->
    @cached = false
    @content = ""

  save: (@content) ->
    @cached = true


class Crawler
  constructor: (@url,options={}) ->
    @current_hash = "#!/"

    @last_ready_state = undefined

    @options = $.extend {}, Crawler.defaults, options

    @routes = {}

    @client = require("webpage").create()
    @client.viewportSize = { width: @options.viewport_width, height: @options.viewport_height }
    @client.onConsoleMessage = (msg) -> console.log "page error: " + msg

    @client.open @url, (status) =>
      if status is "success"
        @wait_for_page()


  gather_hrefs: (str) ->
    links = $(str).find("a")
    that = this
    links.each -> that.add_route $(this).attr("href")
    console.log k for k,v of @routes


  add_route: (href) ->
    if href[0..1] == "#!"
      @routes[href] ?= new Route href


  open_next_uncached_route: ->
    next = ( v for k,v of @routes ).filter( (r) -> !r.cached )[0]
    if next?
      hash = next.hash
      console.log "next hash: " + hash
      @current_hash = hash
    
      hack = -> window.location.hash = ___hash___
      hack = hack.toString().replace("___hash___","'#{hash[1..]}'")

      @client.evaluate hack
      @wait_for_page()


  cache_page: (hash,html) ->
    @add_route hash # in case it doesn't already exist
    @routes[hash]?.save(html)


  wait_for_page: ->
    check_page = =>
      ready_state = @client.evaluate -> $('body').attr("data-status")
      if @last_ready_state != ready_state
        console.log "ASDFGASDGASDGASDG"
        @last_ready_state = ready_state
        @read_page() 
      else 
        console.log @client.evaluate -> window.location.href
        setTimeout check_page, @options.check_page_interval_ms
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

      hash = @client.evaluate -> window.location.hash
      console.log "current hash:" + hash

      console.log hash + " " + @current_hash
      @cache_page hash, html

      @gather_hrefs html
      @open_next_uncached_route()

      # phantom.exit()
    , @options.delay_before_snapshot


  @defaults: {
    check_page_interval_ms: 100 # how often to check if the page said it's ready
    delay_before_snapshot: 0    # how long to wait after that, in case there's animations
    viewport_width: 1024
    viewport_height: 768
  }





new Crawler "http://localhost:3000/#!/"


