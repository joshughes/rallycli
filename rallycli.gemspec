Gem::Specification.new do |spec|
  spec.name        = 'rally_cli'
  spec.version     = '0.1.0'
  spec.date        = '2014-03-29'
  spec.summary     = "Update rally easily with this cli tool"
  spec.description = "Rally CLI tool"
  spec.authors     = ["Joseph Hughes"]
  spec.email       = ''
  spec.files       = ["lib/rally_cli.rb"]
  spec.homepage    =
    'https://github.com/joshughes/rallycli'
  spec.license       = 'Apache 2.0'


  spec.add_dependency 'activesupport', '~> 4.0.4'
  spec.add_dependency 'i18n'
  spec.add_dependency 'rally_api', '~> 0.9.25'
  spec.add_dependency 'thor'
  spec.add_dependency 'highline'


  spec.add_development_dependency "pry"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-mocks"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "test_construct"
end
