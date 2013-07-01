require "sinatra/base"
require "twilio-ruby"
require "json"

class CopperNet < Sinatra::Base
  set :voice, "woman"
  set :logging, true
  #set :bind, "127.0.0.1" # avoid 0.0.0.0 on all interfaces

  before do
    content_type 'application/xml'
  end

  get '/' do
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

  post '/sms' do
    erb :sms, locals: {message: params[:Body]}
  end

  post '/process-private-menu' do
    case params[:Digits].to_i
    when 1
      erb :voicemail
    when 2
      erb :capture_dial_out, locals: {voice: @voice}
    end
  end

  post "dial-out" do
    erb :dial_out, locals: {outgoing_number: params[:Digits], voice: @voice}
  end

  post "/missed-call" do
    puts "CALL STATUS=============================="
    puts params[:DialCallStatus]
    if params[:DialCallStatus] == "no-answer" or params[:DialCallStatus] == "failed"
      erb :missed_call_notification, locals: {missed_number: params[:From]}
    end
  end

  def recognized_number?(number)
    return false if ENV["CELL_NUMBER"].nil? || ENV["VOIP_NUMBER"].nil?
    number == ENV["CELL_NUMBER"] || number == ENV["VOIP_NUMBER"]
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
end

#CopperNet.run! if ENV["RACK_ENV"] != "test"
