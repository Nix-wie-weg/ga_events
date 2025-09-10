# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GaEvents::List' do
  describe '#to_s' do
    it 'generates valid json' do
      GaEvents::Event.new('clicked', { a: 'a' })
      GaEvents::Event.new('clicked', { b: 'b' })
      expect(JSON.parse(GaEvents::List.to_s)).to eq(
        [
          { '__event__' => 'clicked', 'a' => 'a' },
          { '__event__' => 'clicked', 'b' => 'b' }
        ]
      )
    end
  end

  it 'can be initialized with a json string' do
    GaEvents::List.init(<<~JSON.squish)
      [
        { "__event__": "clicked", "a": "a" }
      ]
    JSON

    expect(
      GaEvents::List.send(:data).to_h { [it.event_name, it.event_params] }
    ).to eq({ 'clicked' => { 'a' => 'a' } })
  end

  it 'can be initialized with a broken json string' do
    GaEvents::List.init(<<~JSON.squish)
      [
        { "__event__": "clicked", "trailing": "comma triggers ParserError", }
      ]
    JSON

    expect(
      GaEvents::List.send(:data).to_h { [it.event_name, it.event_params] }
    ).to be_empty
  end
end
