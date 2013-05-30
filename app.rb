require 'sinatra/base'
require 'twilio-ruby'

puts "test"

class CopperNet < Sinatra::Base
  set :voice, "woman"
  set :logging, true
  #set :bind, "127.0.0.1" # avoid 0.0.0.0 on all interfaces

  get '/' do
    content_type 'application/xml'
    if recognized_number?(params[:From])
      erb :private_menu, locals: {voice: @voice}
    else
      erb :forward, locals: {caller_number: params[:From], cell_number: ENV["CELL_NUMBER"], voip_number: ENV["VOIP_NUMBER"]}
    end
  end

  post '/sms' do
    content_type 'application/xml'
    erb :sms, locals: {message: params[:Body]}
  end

  post '/process-private-menu' do
    content_type 'application/xml'
    case params[:Digits].to_i
    when 1
      erb :voicemail
    when 2
      erb :capture_dial_out, locals: {voice: @voice}
    end
  end

  post '/dial-out' do
    content_type 'application/xml'
    erb :dial_out, locals: {outgoing_number: params[:Digits], voice: @voice}
  end

  def recognized_number?(number)
    return false if ENV["CELL_NUMBER"].nil? || ENV["VOIP_NUMBER"].nil?
    number == ENV["CELL_NUMBER"] || number == ENV["VOIP_NUMBER"]
  end
end

puts "ECHOOOOOOO"
puts "ECHO2" if ENV["RACK_ENV"] != "test"
CopperNet.run! if ENV["RACK_ENV"] != "test"
