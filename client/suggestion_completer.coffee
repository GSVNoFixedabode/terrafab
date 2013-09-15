EventEmitter = require("events").EventEmitter

class SuggestionCompleter extends EventEmitter

  constructor: (@inputEl, @listEl, @options={}) ->
    @host = @options.host || 'localhost'
    @port = @options.port || '9200'
    @suggestionField = @options.suggestionField || "suggest"
    @suggestionName = @options.suggestionName || "placesuggest"
    @indexName = @options.indexName || "places"
    @inputEl.on('input', (e) =>
      q = $("#q").val()
      @listEl.empty()
      if q.length > 2
        @getAutoCompleteResults(q).then (result) =>
          @emit('result', result)
          completions = result[@suggestionName][0].options
          $.map(completions, (completion) =>
            @listEl.append("<li data-payload='" +
                JSON.stringify(completion.payload) +
                  "'>"+completion.text+"</li>")
          )
    )
    @index = 0
    @payload = null
    @inputEl.on('keyup', (e) =>
      suggestionEls = $("##{@listEl.attr('id')} li")
      keycode = event.which || event.keyCode
      @index = suggestionEls.index($("##{@listEl.attr('id')} li.selected"))
      switch keycode
        when 40 # Down
          if @index == -1 or @index > suggestionEls.length-2
            @index = 0
          else
            @index++
          console.log @index
          suggestionEls.removeClass('selected')
          $(suggestionEls[@index]).addClass('selected')
          @emit('arrowdown', $("##{@listEl.attr('id')} li.selected").first())
        when 38 # Up
          if @index < 0
            @index = suggestionEls.length-1
          else
            @index--
          suggestionEls.removeClass('selected')
          $(suggestionEls[@index]).addClass('selected')
          @emit('arrowup', $("##{@listEl.attr('id')} li.selected").first())
        when 13 # Enter
          $("##{@listEl.attr('id')} li").removeClass("current")
          @payload = $("##{@listEl.attr('id')} li.selected").first().data("payload")
          @emit('submit', {el: $("##{@listEl.attr('id')} li.selected").first(), payload: @payload})
          $("##{@listEl.attr('id')} li.selected").first().addClass("current")
      false
    )
    @inputEl.on('submit', (e) =>
      e.preventDefault()
      @emit('submit', {el: $("##{@listEl.attr('id')} li.selected").first(), payload: @payload})
      false
    )

  getAutoCompleteResults: (q) ->
    params = '{"' +
      @suggestionName + '": {"text": "' +
        q + '", "completion": {"field": "' +
          @suggestionField +
            '"}}}'
    $.post('http://'+@host + ':' +
        @port +
          '/'+@indexName+'/_suggest', params
    )


module.exports = SuggestionCompleter