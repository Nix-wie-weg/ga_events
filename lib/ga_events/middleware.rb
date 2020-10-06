# frozen_string_literal: true

require 'rack/utils'

module GaEvents
  class Middleware
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
          headers['X-GA-Events'] = serialized

        elsif redirect?(status)
          # 30x/redirect? Then add event list to flash to survive the redirect.
          add_events_to_flash(env, serialized)

        elsif html?(status, headers)
          response = inject_div(response, serialized)
        end
      end

      [status, headers, response]
    end

    private

    def init_event_list(env)
      flash = env['rack.session'] && env['rack.session']['flash'] &&
              env['rack.session']['flash']['flashes']

      # The key has to be removed from the flash here to ensure it does not
      # remain after the finished redirect. This copies the behaviour of the
      # "#use" and "#sweep" methods of the rails flash middleware:
      # https://github.com/rails/rails/blob/v3.2.14/actionpack/lib/action_dispatch/middleware/flash.rb#L220
      GaEvents::List.init(flash&.delete('ga_events'))
    end

    def add_events_to_flash env, serialized_data
      flash = env['rack.session'] && env['rack.session']['flash'] &&
              env['rack.session']['flash']['flashes']

      return unless flash

      flash['ga_events'] = serialized_data
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
