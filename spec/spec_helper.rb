ENV['RACK_ENV'] = 'test'
require_relative '../lib/pail/configuration'
require_relative '../lib/pail/service'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end