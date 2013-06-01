ENV["RACK_ENV"] = "test"
require "rack/test"
require "nokogiri"
require "twilio-test-toolkit"
require File.dirname(__FILE__) + "/../app"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include TwilioTestToolkit::DSL, :type => :feature
end

def app
  CopperNet.new!
end
