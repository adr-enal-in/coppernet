require 'sinatra'
require 'twilio-ruby'

=begin
  ENV VARS
  - Account SID: ENV["ACCOUNT_SID"]
  - Auth token: ENV["AUTH_TOKEN"]
  - Cell number: ENV["CELL_NUMBER"]
  - Twilio number: ENV["TWILIO_NUMBER"]
  - VoIP number: ENV["VOIP_NUMBER"]
=end

#@client = Twilio::REST::Client.new(ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN'])
# shortcut to grab your account object (account_sid is inferred from the client's auth credentials)
#@account = @client.account


# A hack around multiple routes in Sinatra
def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

get '/' do
  #response = Twilio::TwiML::Response.new do |r|
  #  r.Say 'Forwarding your call', :voice => 'woman'
  #end
  #redirect "http://twimlets.com/simulring?PhoneNumbers%5B0%5D=#{ENV["CELL_NUMBER"]}&PhoneNumbers%5B1%5D=#{ENV["VOIP_NUMBER"]}&"
  content_type 'application/xml'
  File.open("#{Dir.pwd}/public/step1.xml", File::RDONLY).readlines
end

get_or_post '/sms' do
  content_type 'application/xml'
  erb :sms
end

=begin
# Voice Request URL
get_or_post '/voice/?' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say 'Forwarding your call', :voice => 'woman'
    r.Dial action: "http://twimlets.com/simulring?PhoneNumbers%5B0%5D=#{ENV["CELL_NUMBER"]}&PhoneNumbers%5B1%5D=#{ENV["VOIP_NUMBER"]}&" do |r|
    end
  end
  response.text
end

# SMS Request URL
get_or_post '/sms/?' do
  response = Twilio::TwiML::Response.new do |r|
    r.Sms "asdasd", to: ENV["CELL_NUMBER"]
  end
  response.text
end

# Twilio Client URL
get_or_post '/client/?' do
  TWILIO_ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID'] || TWILIO_ACCOUNT_SID
  TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN'] || TWILIO_AUTH_TOKEN
  TWILIO_APP_SID = ENV['TWILIO_APP_SID'] || TWILIO_APP_SID

  if !(TWILIO_ACCOUNT_SID && TWILIO_AUTH_TOKEN && TWILIO_APP_SID)
    return "Please run configure.rb before trying to do this!"
  end
  @title = "Twilio Client"
  capability = Twilio::Util::Capability.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
  capability.allow_client_outgoing(TWILIO_APP_SID)
  capability.allow_client_incoming('twilioRubyHackpack')
  @token = capability.generate
  erb :client
end
=end
#simulring(numbers=[]) do
#  response = Twilio::TwiML::Response.new do |r|
#    r.Dial action: "http://twimlets.com/simulring?PhoneNumbers%5B0%5D=#{ENV["CELL_NUMBER"]}&PhoneNumbers%5B1%5D=#{ENV["VOIP_NUMBER"]}&"
#  end
#  puts response.text
#end
