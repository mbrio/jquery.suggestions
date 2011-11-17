$ = jQuery

DATA_ATTR_NODE = 'suggestions-node'

K =
  UP: 38
  DOWN: 40
  TAB: 9
  ENTER: 13
  ESC: 27

class Suggestions
  _request: null
  _timeout: null
  _element: null
  _version: '1.0.0'
  _menuVisible: false
  _forceClose: false
  _options:
    url: '/autocomplete?q=:query'
    timeout: 500
    listClass: 's-l'
    listItemClass: 's-li'
    listItemEmptyClass: 's-lie'
    listItemAnchorClass: 's-lia'
    listItemSelectedClass: 's-lis'
    listItemNoResultsClass: 's-linr'
    listItemLoadingClass: 's-lil'
    listItemErrorClass: 's-lil'
    listZIndex: 500
    defaultHTML: 'Start typing for suggestions'
    defaultLoadingHTML: 'Loading...'
    defaultErrorHTML: 'Error...'
    defaultNoResultsHTML: 'There are no suggestions'
    suggesting: (suggestions)->
    callback: (results) ->
    ajaxError: (jqXHR, textStatus, errorThrown) ->
    parseError: (json) ->

  constructor: (element, options) ->
    @_element = element.attr 'autocomplete', 'off'
    @_options = $.extend @_options, options

    @_menu = $('<ol>').addClass(@_options.listClass).css
      'display': 'none'
      'position': 'absolute'
      'z-index': @_options.listZIndex
    @_update()
    $(document.body).append @_menu
  
    @_element.bind (if $.browser.opera then 'keypress' else 'keydown'), (event) => @_keyDown(event)
    @_element.keyup (event) => @_keyUp(event)
    @_element.blur (event) => @_blur(event)
    @_element.focus (event) => @_focus(event)
    
  _blur: (event) ->
    @hide()
    
  _focus: (event) ->
    @_forceClose = false
    @show()
    
  _keyUp: (event) ->
    return if @_forceClose
    
    switch event.keyCode
      when K.UP, K.DOWN, K.ENTER, K.ESC
        if @_menuVisible then do event.preventDefault
      else @suggest()
      
  _keyDown: (event) ->
    return if @_forceClose
    
    switch event.keyCode
      when K.UP
        return if not @_menuVisible
        
        event.preventDefault()
        selected = @_menu.find "li.#{@_options.listItemSelectedClass}"
        
        if selected?.prev().length > 0
          selected.removeClass @_options.listItemSelectedClass
          selected.prev().addClass @_options.listItemSelectedClass
        
      when K.DOWN
        return if not @_menuVisible
        
        event.preventDefault()
        selected = @_menu.find "li.#{@_options.listItemSelectedClass}"

        if selected?.next().length > 0
          selected.removeClass @_options.listItemSelectedClass
          selected.next().addClass @_options.listItemSelectedClass
      
      when K.ENTER
        return if not @_menuVisible
        
        event.preventDefault()
        selected = @_menu.find "li.#{@_options.listItemSelectedClass} a"
        
        if selected?.get(0)?
          selected.click()
          @hide()
      
      when K.ESC
        return if not @_menuVisible
        
        event.preventDefault()
        @_forceClose = true
        @hide()
    
  hide: ->
    return unless @_menuVisible
    @_halt()
    
    @_menuVisible = false
    @_menu.fadeOut
      duration: 250
      complete: =>
        @_clear()

  show: ->
    return if @_menuVisible
    @_halt()
        
    @_updatePosition()
    
    @_menuVisible = true
    @suggest()
    @_menu.fadeIn
      duration: 250
      
  _updatePosition: ->
    @_menu.css
      left: @_element.offset().left
      top: @_element.offset().top + @_element.outerHeight()
      width: @_element.outerWidth()

  _halt: ->
    @_request?.abort()
    clearTimeout @_timeout if @_timeout?
    
  suggest: ->
    return if @_forceClose

    if not @_menuVisible
      @show() 
    else
      @_options.suggesting?(this)
      @_halt();
    
      if @_element.val() then @_timeout = setTimeout @_suggestMethod(@_element.val()), (@_options.timeout)
      else @_update()
  
  select: (val) ->
    @_element.val(val)
    
  _suggestMethod: (key) ->
    key = (@_options.url).replace ':query', key.toLowerCase()
  
    results = localStorage.getItem key

    if results?
      try
        results = @_parse results
        results = null if results.version is not @_version or (new Date() - results.timestamp).to_minutes() > 5
      catch error
        results = null
        @_update 'error'
        @_options.parseError?(results)

    if results? then () => @_cache(results) else () => @_ajax(key)
  
  _clear: ->
    @_menu.empty()
    
  _update: (results) ->
    @_clear()
    
    if results is 'loading'
      @_menu.append($('<li>').addClass(@_options.listItemLoadingClass).html(@_options.defaultLoadingHTML))
    else if results is 'error'
      @_menu.append($('<li>').addClass(@_options.listItemErrorClass).html(@_options.defaultErrorHTML))
    else if results? and results?.nodes?.length > 0
      for node in results.nodes
        item = $('<li>').addClass(@_options.listItemClass)
        item.addClass(@_options.listItemSelectedClass) if node is results.nodes[0]
        anchor = $('<a href="#">').addClass(@_options.listItemAnchorClass).data(DATA_ATTR_NODE, node).text(node.name)
        anchor.click (event) => @select($(event.target).data(DATA_ATTR_NODE).name)
        
        @_menu.append item.append anchor
    else if results?
      @_menu.append($('<li>').addClass(@_options.listItemNoResultsClass).html(@_options.defaultNoResultsHTML))
    else
      @_menu.append($('<li>').addClass(@_options.listItemEmptyClass).html(@_options.defaultHTML))
  
  _cache: (results) ->
    console.log 'Using localStorage'
    @_update results
    @_options.callback? results
      
  _ajax: (key) ->
    console.log 'Using AJAX'
    
    @_update 'loading'

    @_request = $.ajax
      url: key
      dataType: 'json'
      success: (data) =>
        @_request = null
        
        results = @_preprocessNodes data?.nodes
        localStorage.setItem key, JSON.stringify(results)
        @_update results
        @_options.callback?(results)
      error: (jqXHR, textStatus, errorThrown) =>
        @_update 'error'
        @_options.ajaxError jqXHR, textStatus, errorThrown
  
  _parse: (json) ->
    results = JSON.parse json, (key, value) ->
      if typeof value is 'string'
          a = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value)
          if a then return new Date(Date.UTC(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6]))

      value
    
  _preprocessNodes: (arr) ->
    val = @_element.val().toLowerCase()

    results =
      timestamp: new Date()
      version: @_version
      nodes: (node for node in arr ? [] when node.name.toLowerCase().indexOf(val) is 0)
  
$.fn.suggestions = (options) ->
  this.each (n, obj) ->
    if not $(obj).data('suggestions')? then $(obj).data 'suggestions', new Suggestions($(obj), options)