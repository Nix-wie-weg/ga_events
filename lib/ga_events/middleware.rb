# frozen_string_literal: true

require 'rack/utils'
require 'rack/request'
require 'rack/headers'
require 'cgi'
require 'rubygems'

module GaEvents
  class Middleware
    SESSION_GA_EVENTS_KEY = 'ga_events.events'
    RESPONSE_HEADER = 'x-ga-events'

    HEADERS_KLASS = if Gem::Version.new(Rack.release) < Gem::Version.new('3.0')
                      Rack::Utils::HeaderHash
                    else
                      Rack::Headers
                    end
    private_constant :HEADERS_KLASS

    def initialize(app)
      @app = app
    end

    def call(env)
      init_event_list(env)
      status, headers, body = @app.call(env)

      if GaEvents::List.present?
        headers = HEADERS_KLASS.new.merge(headers)
        request = Rack::Request.new(env)

        # Can outgrow, headers might get too big
        serialized_events = GaEvents::List.to_s
        if xhr_or_turbo?(request)
          # AJAX request
          headers[RESPONSE_HEADER] = CGI.escapeURIComponent(serialized_events)
        elsif redirect?(status)
          # 30x/redirect? Then add event list to rack session to survive the
          # redirect.
          add_events_to_session(env, serialized_events)
        elsif html?(status, headers)
          body = inject_div(body, serialized_events)
        end
      end

      [status, headers, body]
    end

    private

    def init_event_list(env)
      events = env['rack.session']&.delete(SESSION_GA_EVENTS_KEY)
      GaEvents::List.init(events)
    end

    def add_events_to_session env, serialized_data
      if session = env['rack.session']
        session[SESSION_GA_EVENTS_KEY] = serialized_data
      end
    end

    def inject_div(body, serialized_data)
      if body.respond_to?(:to_ary)
        html = +''
        body.to_ary.each { |chunk| html << chunk }
        html.sub!(%r{</body>}i) do |body|
          serialized_data = CGI.escapeHTML(serialized_data)
          "<div data-ga-events=\"#{serialized_data}\"></div>#{body}"
        end
        body = [html]
      end
      body
    ensure
      body.close if body.respond_to?(:close)
    end

    # Taken from:
    # https://github.com/rack/rack-contrib/blob/master/lib/rack/contrib/jsonp.rb
    def html?(status, response_headers)
      !Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.include?(status.to_i) &&
        response_headers.key?('content-type') &&
        response_headers['content-type'].start_with?('text/html')
    end

    def redirect?(status)
      (300..399).cover?(status)
    end

    def xhr_or_turbo?(request)
      request.xhr? ||
        request.env['HTTP_TURBOLINKS_REFERRER'] ||
        request.env['HTTP_X_TURBO_REQUEST_ID']
    end
  end
end
