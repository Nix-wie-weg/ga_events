# GaEvents

Use Google Analytics' Event Tracking everywhere in your Rails app!

This gem alllows you to annotate events everywhere in the code of your Rails
app.
A rack middleware is automatically inserted into the stack. It transports
the event data to the client. Normal requests get a DIV injected, Ajax requests
get a data-pounded custom HTTP header appended. In case of redirects the data
survives inside of rack a rack session.
The asset pipeline-ready CoffeeScript extracts this data on the client-side and
pushes it to Google Analytics via gtag.js or Google Tag Manager.

## Dependencies

* Ruby >= 3.2
* Rails 4.2 onwards
* jQuery

## Installation

Add it to your `Gemfile` with:

```ruby
gem 'ga_events'
```

Run the `bundle` command to install it.

Add to the top of your `application.js` (but after requiring jQuery):

```javascript
//= require ga_events.js
```

After requiring `ga_events.js`, you have to choose an adapter.

### Google Analytics 4 (gtag.js)

```javascript
GaEvents.Event.adapter = function() {
  return new GaEvents.GTagAdapter();
}
```

Optionally you can specify a custom tracker GA_MEASUREMENT_ID where you want
your events to be sent to:

```javascript
GaEvents.Event.adapter = function() {
  return new GaEvents.GTagAdapter(
    {tracker_name: "GA_MEASUREMENT_ID"}
  );
}
```

#### Optional custom object name

The default names of the analytics object for `gtag.js` is  `window.gtag()`. If
you have renamed your analytics object, you can specify the name:

```javascript
GaEvents.Event.adapter = function() {
  return new GaEvents.GTagAdapter(
    {analytics_object_name: "analytics"} // calls window.analytics()
  );
}
```

### Google TagManager

If you are using Google Tag Manager you can add custom events which are then
passed through to Google Analytics.

```javascript
GaEvents.Event.adapter = function() {
  return new GaEvents.GoogleTagManagerAdapter("event_name"); // defaults to ga_event
}
```

### Optional consent settings

Events are flushed immediatly by default. If you need to wait for user consent
you can set `GaEvents.Event.require_user_consent = true`.

With `require_user_consent` enabled all events are buffered until
`GaEvents.Event.user_consent_given = true` is set. Events are flushed as soon
as `GaEvents.Event.flush()` is called.

### Testing

For your testing pleasure we included `NullAdapter`.

```javascript
GaEvents.Event.adapter = function() {
  return new GaEvents.NullAdapter();
}
```

## Usage

On the server-side a new event is added to a list, serialized into a container
element and then added to your HTML response. On Ajax requests a custom
HTTP header is added to the response.

You can create a new event like this:

```ruby
GaEvents::Event.new('example_event', { extra: 'dimension' })
```

On the client-side there is a similar interface to GaEvents:

```javascript
new GaEvents.Event('example_event', { extra: 'dimension' })
```

We have taken special care of tracking events while the DOM is loading.
Events get collected until the DOM is ready and flushed afterwards.

### Too many events

Use something like this snippet to get informed of bloating HTTP headers with
event data:

```ruby
class ApplicationController < ActionController::Base
  after_filter :too_many_ga_events?
  private
  def too_many_ga_events?
    if (serialized = GaEvents::List.to_s).length > 1_024
      notify("GaEvents too big: #{serialized}")
    end
    true
  end
end
```

### Testing

Middlewares aren't loaded in controller specs, so you have to initialize
GaEvents by hand. You can do this eg. in your `spec_helper.rb`:

```ruby
RSpec.configure do |config|
  [...]
  config.before(:each, type: :controller) do
    GaEvents::List.init
  end
end
```

## Contributing

Yes please! Use pull requests.

### Credits

* [danielbayerlein](https://github.com/danielbayerlein) former core committer
* [jhilden](https://github.com/jhilden) for ideas and bug reports
* [brain-geek](https://github.com/brain-geek) for bug fixes, specs, features

## More docs and tools

* [Google Analytics: Event Tracking](https://developers.google.com/analytics/devguides/collection/gajs/eventTrackerGuide)
* [Google Universal Analytics: Event Tracking (gtag.js)](https://developers.google.com/analytics/devguides/collection/gtagjs/events)
* [Google Tag Manager: Custom Events](http://support.google.com/tagmanager/answer/2574372#GoogleAnalytics)
* [Chrome Web Store: Tag Assistant](https://chrome.google.com/webstore/detail/tag-assistant-legacy-by-g/kejbdjndbnbjgmefkgdddjlbokphdefk)
