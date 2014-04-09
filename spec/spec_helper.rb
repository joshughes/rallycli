require 'bundler/setup'
require 'timecop'
require "test_construct/rspec_integration"
require 'coveralls'
require_relative 'helpers/test_helper'
Bundler.setup
Coveralls.wear!


require_relative '../lib/rally/cli' # and any other gems you need

RSpec.configure do |config|
  config.include TestHelper
end
