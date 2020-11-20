# frozen_string_literal: true

%w[middleware engine event list version].each { |f| require "ga_events/#{f}" }
