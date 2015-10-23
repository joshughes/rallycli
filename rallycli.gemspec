Gem::Specification.new do |spec|
  spec.name        = 'rally_cli'
  spec.version     = '0.1.0'
  spec.date        = '2014-03-29'
  spec.summary     = "Update rally easily with this cli tool"
  spec.description = "Rally CLI tool"
  spec.authors     = ["Joseph Hughes"]
  spec.email       = ''
  spec.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.executables   << 'rally_cli'
  spec.homepage      = 'https://github.com/joshughes/rallycli'
  spec.license       = 'Apache 2.0'


  spec.add_dependency 'activesupport', '~> 4.0'
  spec.add_dependency 'i18n'
  spec.add_dependency 'colorize', '~> 0.7.7'
  spec.add_dependency 'rally_api', '~> 1.2'
  spec.add_dependency 'terminal-table', '~> 1.5.2'
  spec.add_dependency 'parallel', '~> 1.6.1'
  spec.add_dependency 'commander'
  spec.add_dependency 'highline'
  spec.add_dependency 'redcarpet'
  spec.add_dependency 'rouge'


  spec.add_development_dependency "pry"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-mocks"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "test_construct"
  spec.add_development_dependency "coveralls"
end
