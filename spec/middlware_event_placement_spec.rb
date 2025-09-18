# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GaEvents::Middleware do
  let(:app) do
    lambda do |env|
      status_code = env.delete('app_status_code').to_i

      GaEvents::Event.new('test', 'event' => 'stuff')
      [status_code, { 'content-type' => 'text/html' }, [<<~HTML]]
        <!doctype html>
        <html lang=en>
          <head>
            <meta charset=utf-8>
            <title>ABC</title>
          </head>
          <body>
            <p>I'm the content</p>
          </body>
        </html>
      HTML
    end
  end

  describe 'html requests' do
    it 'adds events in an injected div' do
      response = make_request
      expect(response.body).to include('<div data-ga-events="[{')
    end

    it 'does no write to rack ression or response headers' do
      session = {}
      response = make_request('rack.session' => session)
      expect(session[GaEvents::Middleware::SESSION_GA_EVENTS_KEY]).to be_nil
      expect(response.headers).not_to have_key(
        GaEvents::Middleware::RESPONSE_HEADER
      )
    end
  end

  describe 'non xhr/fetch redirects' do
    it 'writes to session' do
      session = {}
      make_request('app_status_code' => '302', 'rack.session' => session)
      expect(session[GaEvents::Middleware::SESSION_GA_EVENTS_KEY]).to be_present
    end

    it 'does not inject html or add response headers' do
      response = make_request('app_status_code' => '302', 'rack.session' => {})
      expect(response.body).not_to include('<div data-ga-events="[{')
      expect(response.headers).not_to have_key(
        GaEvents::Middleware::RESPONSE_HEADER
      )
    end
  end

  describe 'xhr requests' do
    it 'adds events as response header' do
      response = make_request('HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest')
      expect(
        response.headers[GaEvents::Middleware::RESPONSE_HEADER]
      ).to include('__event__')
    end

    it 'does not inject a div or writes to session' do
      session = {}
      response =
        make_request(
          'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest',
          'rack.session' => session
        )
      expect(response.body).not_to include('<div data-ga-events')
      expect(session[GaEvents::Middleware::SESSION_GA_EVENTS_KEY]).to be_nil
    end
  end

  describe 'turbolink requests' do
    it 'adds events as response header' do
      response = make_request('HTTP_TURBOLINKS_REFERRER' => '...')
      expect(
        response.headers[GaEvents::Middleware::RESPONSE_HEADER]
      ).to include('__event__')
    end

    it 'does not inject a div with events' do
      response = make_request('HTTP_TURBOLINKS_REFERRER' => '...')
      expect(response.body).not_to include('<div data-ga-events')
    end
  end

  describe 'turbo requests' do
    it 'adds events as response header' do
      response = make_request('HTTP_X_TURBO_REQUEST_ID' => '...')
      expect(
        response.headers[GaEvents::Middleware::RESPONSE_HEADER]
      ).to include('__event__')
    end

    it 'does not inject a div with events' do
      response = make_request('HTTP_X_TURBO_REQUEST_ID' => '...')
      expect(response.body).not_to include('<div data-ga-events')
    end
  end

  private

  def make_request(options = nil)
    middleware = described_class.new(app)
    options = {
      'app_status_code' => '200',
      :lint => true,
      :fatal => true,
      **options
    }
    r = Rack::MockRequest.new(middleware)
    r.get('/', options)
  end
end
