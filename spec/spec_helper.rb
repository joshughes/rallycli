require 'bundler/setup'
require 'timecop'
require_relative 'helpers/task_helper'
Bundler.setup

require 'rally_cli' # and any other gems you need

RSpec.configure do |config|
  config.include TaskHelper
end
