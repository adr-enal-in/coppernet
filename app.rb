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

# A hack around multiple routes in Sinatra
def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

get '/' do
  #response = Twilio::TwiML::Response.new do |r|
  #  r.Say 'Forwarding your call', :voice => 'woman'
  #end
  content_type 'application/xml'
  if params[:From] == ENV["CELL_NUMBER"] && params[:From] == ENV["VOIP_NUMBER"]
    erb :private_menu
  else
    erb :forward, locals: {caller_number: params[:From], cell_number: ENV["CELL_NUMBER"], voip_number: ENV["VOIP_NUMBER"]}
end

get_or_post '/sms' do
  content_type 'application/xml'
  erb :sms, locals: {message: params[:Body]}
end

#simulring(numbers=[]) do
#  response = Twilio::TwiML::Response.new do |r|
#    r.Dial action: "http://twimlets.com/simulring?PhoneNumbers%5B0%5D=#{ENV["CELL_NUMBER"]}&PhoneNumbers%5B1%5D=#{ENV["VOIP_NUMBER"]}&"
#  end
#  puts response.text
#end
