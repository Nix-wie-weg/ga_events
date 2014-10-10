require 'rubygems'
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

  config.before(:each) do
    GaEvents::List.init
  end
end

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}