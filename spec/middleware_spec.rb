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
          GaEvents::Event.new('test', { 'cool' => 'stuff' })
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
            "<div data-ga-events='[{\"__event__\":\"test\",\"cool\":\"stuff\"}]'></div></body>"
          )
        end
      end
    end
  end
end
