require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'rack'
require 'json_api_responders'
require 'pry'

Dir['./spec/support/**/*.rb'].each { |f| require f }
