require 'bundler/setup'
require 'pry'
require 'rspec'
require 'rails'
require 'ga_events'

# Disabling old rspec 'should' syntax
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.raise_errors_for_deprecations!

  config.before do
    GaEvents::List.init
  end
end
