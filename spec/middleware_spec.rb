require 'spec_helper'

describe GaEvents::Middleware do
  let(:app) { proc{[200,{'Content-Type' => 'text/html'},[response_body]]} }
  let(:response_body) { 'Hello, world.' }

  let(:stack) { described_class.new(app) }
  let(:request) { Rack::MockRequest.new(stack) }

  describe "Body code injection" do
    context "no events in GaEvents::List" do
      context "there is no body closing tag" do
        let(:response) { request.get('/') }
        it("leaves everything as it was") { expect(response.body).to eq response_body }
      end

      context "there exists body closing tag" do
        let(:response) { request.get('/') }
        let(:response_body) { 'something awesome!</body>'}

        it("leaves everything as it was") { expect(response.body).to eq response_body }
      end
    end

    context "events present in GaEvents::List" do
      let(:app) {
        proc { |env|
          [200, {'Content-Type' => 'text/html'},
            (GaEvents::Event.new('category', 'action', 'label', 'value'); response_body)
          ]
        }        
      }

      context "there is no body closing tag" do
        let(:response) { request.get('/') }
        it("leaves everything as it was") { expect(response.body).to eq response_body }
      end

      context "there exists body closing tag" do
        let(:response) { request.get('/') }
        let(:response_body) { 'something awesome!</body>'}

        it("injects data-ga-events") do
          expect(response.body).to eq "something awesome!<div data-ga-events='category|action|label|value'></div></body>"
        end
      end
    end    
  end
end
