ENV['RACK_ENV'] = 'test'
require_relative '../lib/vbucket/configuration'
require_relative '../lib/vbucket/service'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end