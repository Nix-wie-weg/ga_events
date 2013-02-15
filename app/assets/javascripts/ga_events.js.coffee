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
      [category, action, label, value] = part.split("|")
      new @(category, action, label, value)

  # Events should not be send to an adapter unless the DOM has finished loading.
  @flush: ->
    if @list.length > 0 and @may_flush
      $.map @list, (event) -> event.push_to_adapter()
      @list = []

  # Add all events to a queue to flush them later
  constructor: (@category, @action, @label, @value) ->
    @klass.list.push @
    @klass.flush()

  push_to_adapter: ->
    # https://developers.google.com/analytics/devguides/collection/gajs/eventTrackerGuide#SettingUpEventTracking
    # Category, Action and Label must be of type string.
    # Value must be a positive integer.

    data =
      action: "#{@action}"
      category: "#{@category}"
    data.label = "#{@label}" if @is_present @label

    if @is_present @value
      # @value is a number and of type integer.
      if isFinite(@value) and Number(@value) % 1 is 0
        # Google Analytics expects a positive integer
        if (value = parseInt @value) > -1
          data.value = value
        else
          throw "Negative integers are not supported at this time."
      else
        throw "The parameter 'value' must be of type integer."

    @klass.adapter().push data

  is_present: (value) -> value? and value != ""

  jQuery =>
    @may_flush = true
    @flush()

    $(document).ajaxComplete (event, xhr) =>
      xhr_events = xhr.getResponseHeader(@header_key)
      @from_string(xhr_events) if xhr_events?

    dom_events = $("div[data-#{@html_key}]").data(@html_key)
    @from_string(dom_events) if dom_events?

class GaEvents.GoogleTagManagerAdapter
  constructor: (@event = "ga_event") ->
  push: (data) ->
    data["event"] = @event
    data["non_interaction"] = true
    window.dataLayer.push(data)

class GaEvents.GoogleAnalyticsAdapter
  push: (obj) ->
    data = ["_trackEvent", obj["category"], obj["action"]]
    data.push(obj["label"]) if obj.label?
    data.push(obj["value"]) if obj.value?
    window._gaq.push(data)

class GaEvents.NullAdapter
  push: (obj) -> console.log obj if console?
