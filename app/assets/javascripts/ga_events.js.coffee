# This file should be required as soon a possible to allow for
# early event tracking.

window.GaEvents = {}

class GaEvents.Event
  adapter: null
  @list: []
  @may_flush: false
  @header_key: "X-GA-Events"
  @html_key: "ga-events"
  klass: @

  # Decompose a dom-string (ruby side) into an event object.
  @from_string: (string) ->
    $.map string.split("$"), (part) =>
      [category, action, label, value] = part.split "|"
      new @(category, action, label, value)

  # Events should not be send to an adapter unless the DOM has finished loading.
  @flush: ->
    if @list.length > 0 and @may_flush
      $.map @list, (event) -> event.push_to_adapter()
      @list = []

  # Add all events to a queue to flush them later
  constructor: (@category = "-", @action = "-", @label = "-", @value = 1) ->
    @klass.list.push @
    @klass.flush()

  to_hash: ->
    # Category, action and label must be of type string.
    action: "#{@action}"
    category: "#{@category}"
    label: "#{@label}"
    # Value has to be a positive integer or defaults to 1
    value: @to_positive_integer(@value)

  to_positive_integer: (n) ->
    if isFinite(n) and parseInt(n) >= 0 then parseInt n else 1

  # https://developers.google.com/analytics/devguides/collection/gajs/eventTrackerGuide#SettingUpEventTracking
  push_to_adapter: -> @klass.adapter().push @to_hash()

  jQuery =>
    @may_flush = true
    @flush()

    $(document).ajaxComplete (event, xhr) =>
      xhr_events = xhr.getResponseHeader @header_key
      @from_string xhr_events if xhr_events?

    dom_events = $("div[data-#{@html_key}]").data @html_key
    @from_string dom_events if dom_events?

class GaEvents.GoogleTagManagerAdapter
  constructor: (@event = "ga_event") ->
  push: (data) ->
    data.event = @event
    data.non_interaction = true
    window.dataLayer.push data

class GaEvents.GoogleUniversalAnalyticsAdapter
  constructor: (@tracker_name = "") ->

  push: (h) ->
    method_call_name = "send"

    if @tracker_name.length > 0
      method_call_name = "#{@tracker_name}.send"

    window.ga method_call_name, "event", h.category, h.action, h.label, h.value,
              {"nonInteraction": true}

class GaEvents.GoogleAnalyticsAdapter
  # Send events non_interactive => no influence on bounce rates
  push: (h) ->
    window._gaq.push(
      ["_trackEvent", h.category, h.action, h.label, h.value, true]
    )

class GaEvents.NullAdapter
  push: (obj) -> console.log obj if console?
