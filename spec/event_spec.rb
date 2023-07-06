require 'spec_helper'

RSpec.describe GaEvents::Event do
  it 'has a custom #to_s implementation ' do
    expect(
      described_class.new('test', { p1: 'my-action', p2: 'my-label' }).to_s
    ).to eq('{"__event__":"test","p1":"my-action","p2":"my-label"}')
  end

  it 'can be restored from hash' do
    initialized_event =
      described_class.new(
        'test',
        {
          'category' => 'my-category',
          'label' => 'my-label',
          'value' => 'my-value'
        }
      )
    from_hash_event =
      described_class.from_hash(
        {
          'category' => 'my-category',
          '__event__' => 'test',
          'label' => 'my-label',
          'value' => 'my-value'
        }
      )
    expect(from_hash_event).to eq initialized_event
  end

  it 'adds itself to GaEvents::List' do
    described_class.from_hash(
      {
        '__event__' => 'test',
        'category' => 'my-category',
        'label' => 'my-label',
        'value' => 'first-value'
      }
    )
    described_class.new('clicked', { some: 'thing' })

    expect(GaEvents::List.to_s).to eq(<<~EVENTS.tr("\n", ''))
      [{"__event__":"test","category":"my-category","label":"my-label","value":"first-value"},
      {"__event__":"clicked","some":"thing"}]
    EVENTS
  end

  it 'can be initialized with a hash' do
    expect(
      described_class.new('one_value', { stars: 5 }).to_s
    ).to eq '{"__event__":"one_value","stars":5}'
    expect(
      described_class.new('two_values', { stars: 5, mode: 'main' }).to_s
    ).to eq '{"__event__":"two_values","stars":5,"mode":"main"}'
    expect(
      described_class.new('with_array', { list: [5, 'stars'] }).to_s
    ).to eq '{"__event__":"with_array","list":[5,"stars"]}'
  end

  it 'can be pattern matched against' do
    event = described_class.new('test', { stars: 5 })
    event => {
      event_name: 'test', event_params: { stars: Integer => five_stars }
    }
    expect(five_stars).to eq 5
  end
end
