require_relative "spec_helper.rb"

describe "Twilio" do
  include Rack::Test::Methods

  it "should load menu" do
    #get "/"
    #doc = Nokogiri::XML(last_response.body)
    #doc.xpath("//Response/Dial").should_not be_nil

    @call = ttt_call("/", 1234567890)
    @call.has_dial?(ENV["CELL_NUMBER"])
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

  it "should recognize blocked numbers" do
    app.is_on_blacklist?(3102003399).should be_true
  end

  it "should block blocked numbers" do
    get "/", {:From => 3102003399}
    doc = Nokogiri::XML(last_response.body)
    doc.xpath("//Response/Say").first.content.should == "This number is no longer in service"
  end
end
