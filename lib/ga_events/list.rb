# frozen_string_literal: true

# NOTE: Collecting the events is thread-safe, but will cause problems in an
#       asynchronous/evented environment.

require 'forwardable'

module GaEvents
  module List
    class << self
      extend Forwardable
      def_delegators :data, :<<, :present?

      def to_s
        "[#{data.collect(&:to_s).join(',')}]"
      end

      # Init list, optionally with a string of serialized events
      def init(str = nil)
        Thread.current[:ga_events] = []
        if str.present?
          raw_events = JSON.parse(str)
          raw_events.each { |raw_event| GaEvents::Event.from_hash(raw_event) }
        end
      rescue JSON::ParserError
        nil
      end

      private

      def data
        Thread.current[:ga_events]
      end
    end
  end
end
