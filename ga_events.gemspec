# frozen_string_literal: true

require File.expand_path('lib/ga_events/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ['Florian Dütsch', 'Sven Winkler']
  gem.email         = ['florian.duetsch@nix-wie-weg.de',
                       'sven.winkler@nix-wie-weg.de']
  gem.description   =
    "Google Analytics' Event Tracking everywhere in your Rails app)"
  gem.summary       = 'This gem allows you to annotate events everywhere in ' \
                      'the code of your Rails app. A rack middleware is ' \
                      'automatically inserted into the stack. It transports ' \
                      'the event data to the client. Normal requests get a ' \
                      'DIV injected, AJAX requests get a data-pounded custom ' \
                      'HTTP header appended.  The asset pipeline-ready ' \
                      'CoffeeScript extracts this data on the client side ' \
                      'and pushes it to Google Analytics via ga.js or Google ' \
                      'Tag Manager.'
  gem.homepage      = 'https://github.com/Nix-wie-weg/ga_events'

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'ga_events'
  gem.require_paths = ['lib']
  gem.version       = GaEvents::VERSION
  gem.licenses      = ['MIT']

  gem.required_ruby_version = '>= 2.3'
  gem.add_dependency 'rails', '>= 4.2'
end
