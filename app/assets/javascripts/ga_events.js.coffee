# TODO Sven: Dokumentieren, wie und wann diese Datei geladen werden sollte.
# TODO Sven: Englische Kommmentare
window.GaEvents = {}

class GaEvents.Event
  @list: []
  @may_flush: false
  @header_key: "X-GA-Events"
  @html_key: "ga-events"
  klass: @

  @from_string: (string) ->
    $.map string.split("$"), (part) =>
      [category, action, label, value] = part.split("|")
      new @(category, action, label, value)

  # Events dürfen nicht direkt zu Analytics gesendet werden, sondern erst
  # wenn das DOM bereit ist. Zu diesem Zweck müssen alle vorherigen Events
  # eingesammelt werden.
  @flush: ->
    if @list.length > 0 and @may_flush
      $.map @list, (event) -> event.push_to_analytics()
      @list = []

  constructor: (@category, @action, @label, @value) ->
    @klass.list.push @
    @klass.flush()

  push_to_analytics: ->
    data =
      action: @action
      category: @category
      event: 'ga_event'
      non_interaction: true
    data.label = @label if @is_valid_value(@label)
    data.value = @value if @is_valid_value(@value)
    dataLayer.push data

  is_valid_value: (value) -> value? and value != ''

  jQuery =>
    @may_flush = true
    @flush()

    $(document).ajaxComplete (event, xhr) =>
      xhr_events = xhr.getResponseHeader(@header_key)
      @from_string(xhr_events) if xhr_events?

    dom_events = $("div[data-#{@html_key}]").data(@html_key)
    @from_string(dom_events) if dom_events?

