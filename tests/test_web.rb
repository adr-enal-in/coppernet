ENV["RACK_ENV"] = "test"
require File.dirname(__FILE__) + "/../app"
require "rack/test"
require "nokogiri"

describe "Twilio" do
  include Rack::Test::Methods

  def app
    CopperNet.new!
  end

  it "should load menu" do
    get "/"
    #last_response.should be_ok
    doc = Nokogiri::XML(last_response.body)
    doc.xpath("//Response/Dial").should_not be_nil
  end

  it "should load private menu" do
    get "/", {:From => ENV["CELL_NUMBER"]}
    doc = Nokogiri::XML(last_response.body)
    doc.xpath("//Response/Gather").first["action"].should == "/process-private-menu"
  end

  it "should recognize cell number" do
    app.recognized_number?(ENV["CELL_NUMBER"]).should be_true
  end

  it "should recognize VOIP number" do
    app.recognized_number?(ENV["VOIP_NUMBER"]).should be_true
  end

  it "should forward emails" do
    sms_body = "testing sms"
    post "/sms", {:Body => sms_body}
    doc = Nokogiri::XML(last_response.body)
    doc.xpath("//Response/Sms").first.content.should == sms_body
  end

  it "should ask for dial out" do
    post "/process-private-menu", {:Digits => 2}
    doc = Nokogiri::XML(last_response.body)
    doc.xpath("//Response/Gather").first["action"].should == "/dial-out"
  end
end
