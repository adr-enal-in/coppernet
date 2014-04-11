require 'sinatra/base'
require 'twilio-ruby'
require 'json'
require 'pony'

class CopperNet < Sinatra::Base
  set :voice, "woman"
  set :logging, true
  #set :bind, "127.0.0.1" # avoid 0.0.0.0 on all interfaces

  before do
    content_type 'application/xml'
  end

  # Web homepage
  get "/" do
    content_type 'text/html'
    erb :web_homepage
  end

  get "/voice/?" do
    if recognized_number?(params[:From])
      erb :private_menu, locals: {voice: @voice}
    else
      if is_on_blacklist?(params[:From])
        erb :blocked_caller, locals: {voice: @voice}
      else
        erb :forward, locals: {caller_number: params[:From], phone_numbers: ENV["PHONE_NUMBERS"].split(',')}
      end
    end
  end

  post "/sms/?" do
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
    Pony.mail({
      :to => ENV["NOTIFY_EMAIL"],
      :from => "dakotah@teardrop.co",
      :subject => "Missed call from " + params[:From],
      :body => "At #{Time.now} you missed a call from " + params[:From],
      :via => :smtp,
      :via_options => {
        :port           => '587',
        :address        => 'smtp.mandrillapp.com',
        :user_name      => ENV['MANDRILL_USERNAME'],
        :password       => ENV['MANDRILL_APIKEY'],
        :domain         => 'heroku.com', # the HELO domain provided by the client to the server
        :authentication => :plain # :plain, :login, :cram_md5, no auth by default
      }
    })

    #if params[:DialCallStatus] == "no-answer" or params[:DialCallStatus] == "failed"
    #  erb :missed_call_notification, locals: {missed_number: params[:From]}
    #end
  end

  ##
  ## Admin area
  ##

  get "/admin" do
    content_type 'text/html'
    protected!
    erb :admin, locals: {
      phone_numbers: ENV["PHONE_NUMBERS"],
      sms_forwarding: ENV["SMS_FORWARDING"],
      twilio_number: ENV["TWILIO_NUMBER"],
      notify_email: ENV["NOTIFY_EMAIL"]
    }
  end

  post "/admin" do
    protected!
    ENV["SMS_FORWARDING"] = params[:sms_forwarding]
    ENV["PHONE_NUMBERS"] = params[:phone_numbers]
    ENV["TWILIO_NUMBER"] = params[:twilio_number]
    ENV["NOTIFY_EMAIL"] = params[:notify_email]
    redirect to('/admin')
  end

  def recognized_number?(incoming_number)
    ENV["PHONE_NUMBERS"].split(',').each do |number|
      return true if incoming_number == number
    end
    false
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

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="CopperNet Admin"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV["ADMIN_USERNAME"], ENV["ADMIN_PASSWORD"]]
    end
  end
end


#CopperNet.run! if ENV["RACK_ENV"] != "test"
