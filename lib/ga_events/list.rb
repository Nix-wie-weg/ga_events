# NOTE: Collecting the events is thread-safe, but will cause problems in an
#       asynchronous environment.

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

  def self.init
    Thread.current[:ga_events] = []
  end

  def self.data
    Thread.current[:ga_events]
  end

  private_class_method :data
end
