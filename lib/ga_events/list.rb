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
        data.collect(&:to_s).join('$')
      end

      # Init list, optionally with a string of serialized events
      def init(str = nil)
        Thread.current[:ga_events] = []
        (str || '').split('$').each { |s| GaEvents::Event.from_string(s) }
      end

      private

      def data
        Thread.current[:ga_events]
      end
    end
  end
end
