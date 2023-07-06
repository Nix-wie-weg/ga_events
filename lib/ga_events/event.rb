# frozen_string_literal: true

module GaEvents
  class Event
    attr_reader :event_name, :event_params

    # Default values are set here, see README.md for details.
    def initialize(event_name, event_params = {})
      @event_name = event_name
      @event_params = event_params
      GaEvents::List << self
    end

    def to_s
      JSON.generate({ __event__: event_name, **event_params })
    end

    def to_h
      { event_name:, event_params: event_params.symbolize_keys }
    end

    def deconstruct_keys(keys)
      keys ? to_h.slice(*keys) : to_h
    end

    def self.from_hash(event_hash)
      if event_name = event_hash.delete('__event__')
        new(event_name, event_hash)
      end
    end

    def ==(other)
      self.class == other.class && event_name == other.event_name &&
        event_params == other.event_params
    end
  end
end
