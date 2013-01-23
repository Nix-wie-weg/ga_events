# GaEvents

Use Google Analytics' Event Tracking everywhere in your Rails app!

This gem alllows you to annotate events everywhere in the code of your Rails
app.
A rack middleware is automatically inserted into the stack. It transports
the event data to the client. Normal requests get a DIV injected, AJAX requests
get a data-pounded custom HTTP header appended.
The asset pipeline-ready CoffeeScript extracts this data on the client side and
pushes it Google Analytics or Google Tag Manager.

# TODO Sven: Wenn Text gegengelesen, dann ebenfalls als gem summary verwenden

## Usage

# TODO Sven: Kurze Dokumentation
# * Wie erzeugt man events?
# * JS-Einbindung
# * Details zum Tag Manager sinnvoll? -> Daniel?

### Too much events

Use something like this snippet to get informed of bloating HTTP headers with
event data:

    class ApplicationController < ActionController::Base
      after_filter :too_much_ga_events?
      private
      def too_much_ga_events?
        if (serialized = GaEvents::List.to_s).length > 1_024
          notify("GaEvents too big: #{serialized}")
        end
        true
      end
    end

## Contributing

Yes please! Use pull requests.

## More docs

* [Google Analytics: Event Tracking](https://developers.google.com/analytics/devguides/collection/gajs/eventTrackerGuide)
