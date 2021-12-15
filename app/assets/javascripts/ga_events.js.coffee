# This file should be required as soon a possible to allow for
# early event tracking.

window.GaEvents = {}

class GaEvents.Event
  adapter: null
  @list: []
  @may_flush: false
  @header_key: "X-GA-Events"
  @html_key: "ga-events"
  @require_user_consent: false
  @user_consent_given: false
  klass: @

  # Decompose an event-string (ruby side) into an event object.
  @from_string: (string) ->
    $.map string.split("$"), (part) =>
      [category, action, label, value] = part.split "|"
      new @(category, action, label, value)

  @from_dom: ->
    dom_events = $("div[data-#{@html_key}]").data @html_key
    @from_string dom_events if dom_events?

  # Events should not be sent to an adapter unless the DOM has finished loading.
  @flush: ->
    return if @require_user_consent && !@user_consent_given

    if @list.length > 0 and @may_flush
      $.map @list, (event) -> event.push_to_adapter()
      @list = []

  # Add all events to a queue to flush them later
  constructor: (@category = "-", @action = "-", @label = "-", @value = 1) ->
    @klass.list.push @
    @klass.flush()

  escape: (str) ->
    return unless str
    "#{str}".replace(/ä/g, "ae")
            .replace(/ö/g, "oe")
            .replace(/ü/g, "ue")
            .replace(/Ä/g, "Ae")
            .replace(/Ö/g, "Oe")
            .replace(/Ü/g, "Ue")
            .replace(/ß/g, "ss")

  to_hash: ->
    # Category, action and label must be escaped and of type string.
    action: @escape(@action)
    category: @escape(@category)
    label: @escape(@label)
    # Value has to be a positive integer or defaults to 1
    value: @to_positive_integer(@value)

  to_positive_integer: (n) ->
    if isFinite(n) and parseInt(n) >= 0 then parseInt n else 1

  push_to_adapter: -> @klass.adapter().push @to_hash()

  jQuery =>
    @may_flush = true
    @flush()

    process_xhr = (xhr) =>
      xhr_events = xhr.getResponseHeader @header_key
      @from_string xhr_events if xhr_events?

    $(document).ajaxComplete((_, xhr) -> process_xhr(xhr))
    $(document).on "turbolinks:request-end", (event) ->
      xhr = event.originalEvent.data.xhr
      process_xhr(xhr)

    @from_dom()


class GaEvents.GoogleTagManagerAdapter
  constructor: (@event = "ga_event") ->
  push: (data) ->
    data.event = @event
    data.non_interaction = true
    window.dataLayer.push data

class GaEvents.GoogleUniversalAnalyticsAdapter
  @script_version = "analytics.js"
  @custom_dataLayer_push_method_name = false

  constructor: (@method_call_name = "send", tracker_name) ->
    @method_call_name = "#{tracker_name}.#{@method_call_name}" if tracker_name

  push: (data) ->
    gtag_version = @script_version == "gtag.js"
    push_method_name =
      if @custom_dataLayer_push_method_name
        @custom_dataLayer_push_method_name
      else if gtag_version
        "gtag"
      else
        "ga"

    if gtag_version
      window[push_method_name](
        "event", data.action,
        {
          "event_category": data.category,
          "event_label": data.label,
          "value": data.value,
          "non_interaction": true
        }
      )
    else
      window[push_method_name](
        @method_call_name, "event",
        data.category, data.action, data.label, data.value,
        {"nonInteraction": true}
      )

class GaEvents.GoogleAnalyticsAdapter
  # https://developers.google.com/analytics/devguides/collection/gajs/eventTrackerGuide#SettingUpEventTracking
  # Send events non_interactive => no influence on bounce rates
  push: (data) ->
    window._gaq.push(
      ["_trackEvent", data.category, data.action, data.label, data.value, true]
    )

class GaEvents.NullAdapter
  push: (obj) -> console.log obj if console?

class GaEvents.TestAdapter
  push: (obj) ->
    window.events = [] unless window.events?
    window.events.push obj
