# frozen_string_literal: true

require 'rack/utils'

module GaEvents
  class Middleware
    SESSION_GA_EVENTS_KEY = 'ga_events.events'

    def initialize(app)
      @app = app
    end

    def call(env)
      init_event_list(env)
      status, headers, response = @app.call(env)

      headers = Rack::Utils::HeaderHash.new(headers)
      if GaEvents::List.present?
        request = Rack::Request.new(env)

        # Can outgrow, headers might get too big
        serialized = GaEvents::List.to_s
        if xhr_or_turbolinks?(request)
          # AJAX request
          headers['x-ga-events'] = CGI.escapeURIComponent(serialized)
        elsif redirect?(status)
          # 30x/redirect? Then add event list to rack session to survive the
          # redirect.
          add_events_to_session(env, serialized)
        elsif html?(status, headers)
          response = inject_div(response, serialized)
        end
      end

      [status, headers, response]
    end

    private

    def init_event_list(env)
      events = env['rack.session']&.delete(SESSION_GA_EVENTS_KEY)
      GaEvents::List.init(events)
    end

    def add_events_to_session env, serialized_data
      if session = env.dig('rack.session')
        session[SESSION_GA_EVENTS_KEY] = serialized_data
      end
    end

    def normalize_response(response)
      response = response.body if response.respond_to?(:body)
      response = response.join if response.respond_to?(:join)
      response
    end

    def inject_div(response, serialized_data)
      r = normalize_response(response)
      [r.sub('</body>', "<div data-ga-events='#{serialized_data}'></div>\\0")]
    end

    # Taken from:
    # https://github.com/rack/rack-contrib/blob/master/lib/rack/contrib/jsonp.rb
    def html?(status, headers)
      !Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.include?(status.to_i) &&
        headers.key?('Content-Type') &&
        headers['Content-Type'].include?('text/html')
    end

    def redirect?(status)
      (300..399).cover?(status)
    end

    def xhr_or_turbolinks?(request)
      request.xhr? || request.env['HTTP_TURBOLINKS_REFERRER']
    end
  end
end
