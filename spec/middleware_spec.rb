# frozen_string_literal: true

require 'spec_helper'

describe GaEvents::Middleware do
  let(:app) do
    proc { [200, { 'Content-Type' => 'text/html' }, [response_body]] }
  end
  let(:response_body) { 'Hello, world.' }

  let(:stack) { described_class.new(app) }
  let(:request) { Rack::MockRequest.new(stack) }

  describe 'Body code injection' do
    context 'no events in GaEvents::List' do
      context 'there is no body closing tag' do
        let(:response) { request.get('/') }
        it 'leaves everything as it was' do
          expect(response.body).to eq response_body
        end
      end

      context 'there exists body closing tag' do
        let(:response) { request.get('/') }
        let(:response_body) { 'something awesome!</body>' }

        it 'leaves everything as it was' do
          expect(response.body).to eq response_body
        end
      end
    end

    context 'events present in GaEvents::List' do
      let(:app) do
        proc do |_|
          GaEvents::Event.new(
            'test',
            'cool' => 'stuff',
            'ding' => ["it's a bug", 'this is "fine"', 'x=1&y=2', '>:3<']
          )
          [200, { 'Content-Type' => 'text/html' }, response_body]
        end
      end

      context 'when no body closing tag exists' do
        let(:response) { request.get('/') }
        it 'leaves everything as it was' do
          expect(response.body).to eq response_body
        end
      end

      context 'when a body closing tag exists' do
        let(:response) { request.get('/') }
        let(:response_body) { 'something awesome!</body>' }

        it 'injects data-ga-events' do
          expect(response.body).to eq(
            'something awesome!' \
            '<div data-ga-events="[{' \
            '&quot;__event__&quot;:&quot;test&quot;,' \
            '&quot;cool&quot;:&quot;stuff&quot;,' \
            '&quot;ding&quot;:[' \
              '&quot;it&#39;s a bug&quot;,' \
              '&quot;this is \&quot;fine\&quot;&quot;,' \
              '&quot;x=1&amp;y=2&quot;,' \
              '&quot;&gt;:3&lt;&quot;' \
            ']' \
          '}]"></div></body>'
          )
        end
      end
    end
  end
end
