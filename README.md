# GaEvents

Use Google Analytics' Event Tracking everywhere in your Rails app!

This gem alllows you to annotate events everywhere in the code of your Rails
app.
A rack middleware is automatically inserted into the stack. It transports
the event data to the client. Normal requests get a DIV injected, Ajax requests
get a data-pounded custom HTTP header appended. In case of redirects the data
survives inside Rails' flash.
The asset pipeline-ready CoffeeScript extracts this data on the client-side and
pushes it to Google Analytics via ga.js or Google Tag Manager.

## Dependencies

* Rails 3.1 onwards
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

After requiring `ga_events.js`, choose an adapter.

For stock Google Analytics (ga.js) use:

```javascript
GaEvents.Event.adapter = function() {
  return new GaEvents.GoogleAnalyticsAdapter();
}
```

For Google Universal Analytics (analytics.js) use:

```javascript
GaEvents.Event.adapter = function() {
  return new GaEvents.GoogleUniversalAnalyticsAdapter();
}
```

If you are using Google Tag Manager you can add custom events which are then
passed through to Google Analytics.

```javascript
GaEvents.Event.adapter = function() {
  return new GaEvents.GoogleTagManagerAdapter("event_name"); // defaults to ga_event
}
```

If you are using a staging system you can use the `NullAdapter`.

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
GaEvents::Event.new(category, action, label, value)
```

On the client-side there is a similar interface to GaEvents:

```javascript
new GaEvents.Event(category, action, label, value)
```

We have taken special care of tracking events while the DOM is loading.
Events get collected until the DOM is ready and flushed afterwards.

### Default values

While collecting hundreds of thousands of events on a daily basis in
Google Analytics we found corrupted aggregated events when the event label or
value is omitted. We now enforce a default label ("-") and value (1).

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

```ruby spec_helper.rb
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

* [jhilden](https://github.com/jhilden) for ideas and bug reports

## More docs and tools

* [Google Analytics: Event Tracking](https://developers.google.com/analytics/devguides/collection/gajs/eventTrackerGuide)
* [Google Tag Manager: Custom Events](http://support.google.com/tagmanager/answer/2574372#GoogleAnalytics)
* [Chrome Web Store: Event Tracking Tracker](https://chrome.google.com/webstore/detail/event-tracking-tracker/npjkfahkbgoagkfpkidpjdemjjmmbcim)
