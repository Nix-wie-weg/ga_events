# frozen_string_literal: true

module GaEvents
  Event = Struct.new(:category, :action, :label, :value) do
    # Default values are set here, see README.md for details.
    def initialize(category = '-', action = '-', label = '-', value = 1)
      super
      GaEvents::List << self
    end

    def to_s
      [category, action, label, value].join('|')
    end

    def self.from_string(str)
      new(*str.split('|'))
    end
  end
end
