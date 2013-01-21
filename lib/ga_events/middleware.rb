require 'rack/utils'

module GaEvents
  class Middleware

    def initialize(app)
      @app = app
    end
    def call(env)
      GaEvents::List.init
      status, headers, response = @app.call(env)
      headers = Rack::Utils::HeaderHash.new(headers)

      if GaEvents::List.present?
        request = Rack::Request.new(env)

        # Can outgrow, headers might get to big
        # TODO: Document a notification solution
        serialized = GaEvents::List.to_s

        if request.xhr?
          headers['X-GA-Events'] = serialized
        elsif is_html?(status, headers)
          new_body = response.body.sub('</body>',
            "<div data-ga-events='#{serialized}'></div>\\0")
          response = [new_body]
        end
      end

      [status, headers, response]
    end

    private

    # Taken from:
    # https://github.com/rack/rack-contrib/blob/master/lib/rack/contrib/jsonp.rb
    def is_html?(status, headers)
      !Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.include?(status.to_i) &&
        headers.key?('Content-Type') &&
        headers['Content-Type'].include?('text/html')
    end
  end
end

