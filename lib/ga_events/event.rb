module GaEvents
  class Event < Struct.new(:category, :action, :label, :value)
    # TODO: Link zu documentation regarding fixed label and value != nil
    def initialize(category, action, label, value = 1)
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
