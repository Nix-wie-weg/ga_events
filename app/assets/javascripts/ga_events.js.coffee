# This file should be required as soon a possible to allow for
# early event tracking.

window.GaEvents = {}

class GaEvents.Event
  adapter: null
  @list: []
  @may_flush: false
  @header_key: "x-ga-events"
  @html_key: "ga-events"
  @require_user_consent: false
  @user_consent_given: false
  klass: @

  # Decompose an event-string (ruby side) into an event object.
  @from_json: (string) ->
    events = JSON.parse(string)

    $.map events, (event) =>
      if event_name = event.__event__
        delete event.__event__
        new @(event_name, event)

  @from_dom: ->
    data_attribute = "data-#{@html_key}"
    dom_events = $("div[#{data_attribute}]").attr data_attribute
    @from_json dom_events if dom_events?

  # Events should not be sent to an adapter unless the DOM has finished loading.
  @flush: ->
    return if @require_user_consent && !@user_consent_given

    if @list.length > 0 and @may_flush
      $.map @list, (event) -> event.push_to_adapter()
      @list = []

  # Add all events to a queue to flush them later
  constructor: (@event_name, @options = {}) ->
    @klass.list.push @
    @klass.flush()

  push_to_adapter: ->
    if @is_valid_event_name()
      @klass.adapter().push(@event_name, @options)
    else
      console.warn("GA4 event name \"#{@event_name}\" is invalid.") if console

  # https://support.google.com/analytics/answer/13316687?hl=en#zippy=%2Cweb
  is_valid_event_name: -> /^[a-z]+[a-z0-9_]*$/i.test(@event_name)

  jQuery =>
    @may_flush = true
    @flush()

    process_xhr = (xhr) =>
      xhr_events = xhr.getResponseHeader @header_key
      @from_json decodeURIComponent(xhr_events) if xhr_events?

    $(document).ajaxComplete((_, xhr) -> process_xhr(xhr))
    $(document).on "turbolinks:request-end", (event) ->
      xhr = event.originalEvent.data.xhr
      process_xhr(xhr)

    @from_dom()


class GaEvents.GTagAdapter
  constructor: (options) ->
    @analytics_object_name = options?.analytics_object_name || 'gtag'

    # https://developers.google.com/analytics/devguides/migration/ua/analyticsjs-to-gtagjs#measure_pageviews_with_specified_trackers
    @tracker_name = options?.tracker_name || false

  push: (event_name, data) ->
    data.send_to = @tracker_name if @tracker_name
    window[@analytics_object_name]("event", event_name, data)

class GaEvents.NullAdapter
  push: (event_name, data) -> console.log(event_name, data) if console?

class GaEvents.GoogleTagManagerAdapter
  constructor: (@event = "ga_event") ->

  push: (event_name, data) ->
    data.event = @event
    data.event_name = event_name
    data.non_interaction = true
    window.dataLayer.push data

class GaEvents.TestAdapter
  push: (event_name, data) ->
    loggedEvent = Object.assign({ event_name: event_name }, data)
    window.events = [] unless window.events?
    window.events.push(loggedEvent)
