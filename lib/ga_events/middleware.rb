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
        if request.xhr? || request.env['HTTP_TURBOLINKS_REFERRER']
          # AJAX request
          headers['X-GA-Events'] = serialized

        elsif (300..399).include?(status)
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
      # Handle events stored in flash
      # Parts borrowed from Rails:
      # https://github.com/rails/rails/blob/v3.2.14/actionpack/lib/action_dispatch/middleware/flash.rb
      flash = env['rack.session'] && env['rack.session']['flash']

      # Fix for Rails 4
      flash &&= flash['flashes'] if Rails::VERSION::MAJOR > 3

      GaEvents::List.init(flash && flash['ga_events'])
    end

    def add_events_to_flash env, serialized_data
      flash_hash = env[ActionDispatch::Flash::KEY]
      flash_hash ||= ActionDispatch::Flash::FlashHash.new
      flash_hash['ga_events'] = serialized_data
      # Discard the flash after the action completes.
      flash_hash.discard('ga_events')

      env[ActionDispatch::Flash::KEY] = flash_hash
    end

    def normalize_response(r)
      r = r.body if r.respond_to?(:body)
      r = r.join if r.respond_to?(:join)
      r
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
  end
end
