module GaEvents
  class Event < Struct.new(:category, :action, :label, :value)
    # Default values are set here, see README.md for details.
    def initialize(category = '-', action = '-', label = '-', value = 1)
      super
      GaEvents::List << self
    end

    def to_s
      ([category, action, label].map { |e| URI.encode(e) } + [value]).join('|')
    end

    def self.from_string(str)
      new(*str.split('|').map { |e| URI.decode(e) })
    end
  end
end
