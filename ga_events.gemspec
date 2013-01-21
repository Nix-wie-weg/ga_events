# encoding: utf-8
require File.expand_path('../lib/ga_events/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Florian Dütsch', 'Sven Winkler']
  gem.email         = ['florian.duetsch@nix-wie-weg.de',
                       'sven.winkler@nix-wie-weg.de']
  gem.description   =
    %q{Google Analytics' Event Tracking everywhere in your Rails app}
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/Nix-wie-weg/ga_events'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ga_events"
  gem.require_paths = ["lib"]
  gem.version       = GaEvents::VERSION

  gem.add_dependency 'rails', '~> 3.1'
end
