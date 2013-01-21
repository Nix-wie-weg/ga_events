
module GaEvents
  class Event < Struct.new(:category, :action, :label, :value)
    def initialize(category, action, label = nil, value = nil)
      super
      GaEvents::List << self
    end
    # TODO Sven: Wird die Pipe escapet? Dann besser anderes Trennzeichen?
    def to_s
      [category, action, label, value].join('|')
    end
  end
end

