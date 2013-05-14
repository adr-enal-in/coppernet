require "sinatra"
require "twilio-ruby"
require "json"

@voice = "woman"

# A hack around multiple routes in Sinatra
def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

def recognized_number?(number)
  return false if ENV["CELL_NUMBER"].nil? || ENV["VOIP_NUMBER"].nil?
  number == ENV["CELL_NUMBER"] || number == ENV["VOIP_NUMBER"]
end

get '/' do
  content_type 'application/xml'
  if recognized_number?(params[:From])
    erb :private_menu, locals: {voice: @voice}
  else
    if is_on_blacklist?(params[:From])
      erb :blocked_caller, locals: {voice: @voice}
    else
      erb :forward, locals: {caller_number: params[:From], cell_number: ENV["CELL_NUMBER"], voip_number: ENV["VOIP_NUMBER"]}
    end
  end
end

get_or_post '/sms' do
  content_type 'application/xml'
  erb :sms, locals: {message: params[:Body]}
end

get_or_post '/process-private-menu' do
  content_type 'application/xml'
  case params[:Digits].to_i
  when 1
    erb :voicemail
  when 2
    erb :capture_dial_out, locals: {voice: @voice}
  end
end

get_or_post '/dial-out' do
  content_type 'application/xml'
  erb :dial_out, locals: {outgoing_number: params[:Digits], voice: @voice}
end

def is_on_blacklist?(caller_number)
  begin
    uri = URI.parse(ENV["BLACKLIST_URL"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    blacklist = JSON.parse(response.body)
    blacklist.each do |record|
      return true if record["number"].to_i == caller_number.to_i
    end
    false
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
    false
  end
end
