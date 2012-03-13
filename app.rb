require "sinatra"
require "active_record"
require "logger"
ActiveRecord::Base.logger = Logger.new(STDOUT)

Dir.glob("models/*"){|model| require_relative model}

class ChordProShare < Sinatra::Base
  require_relative "config/database.rb"

  register Sinatra::Warden

  get "/" do
    authorize!("/login")
    haml :index
  end
end
