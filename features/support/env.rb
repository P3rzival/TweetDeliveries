require 'capybara'
require 'rspec'
require 'capybara/cucumber'

## Uncomment to enable SimpleCov
require 'simplecov'

SimpleCov.start do
  add_filter 'features/'
end

require_relative '../../iteration2.rb'

ENV['RACK_ENV'] = 'test'

Capybara.app = Sinatra::Application

class Sinatra::ApplicationWorld
  include RSpec::Expectations
  include RSpec::Matchers
  include Capybara::DSL
end

World do
  Sinatra::ApplicationWorld.new  
end