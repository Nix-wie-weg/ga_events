# NOTE: Collecting the events is thread-safe, but will cause problems in an
#       asynchronous/evented environment.

module GaEvents::List
  def self.<<(event)
    data << event
  end

  def self.to_s
    data.collect(&:to_s).join('$')
  end

  def self.present?
    data.present?
  end

  # Init list, optionally with a string of serialized events
  def self.init(str = nil)
    Thread.current[:ga_events] = []
    (str || '').split('$').each { |s| GaEvents::Event.from_string(s) }
  end

  def self.data
    Thread.current[:ga_events]
  end

  private_class_method :data
end
