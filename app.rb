require "sinatra"
require "omniauth"
require "omniauth-identity"
require "active_record"
require "logger"
ActiveRecord::Base.logger = Logger.new(STDOUT)

Dir.glob("models/*"){|model| require_relative model}

class ChordProShare < Sinatra::Base
  require_relative "config/database.rb"
  use Rack::Session::Cookie
  use OmniAuth::Strategies::Identity, :field => [:email]

  set :haml, :format => :html5

  helpers do
    def authorized?
      !user.nil?
    end

    def logout
      self.user = nil
    end

    def user
      session["user"]
    end

    def user=(auth)
      session["user"] = auth
    end
  end

  %w(get post).each do |method|
    send(method, "/auth/:provider/callback") do
      auth = env["omniauth.auth"]
      self.user = User.from_omniauth(auth)
      redirect "/"
    end
  end

  get "/" do
    redirect "/auth/identity" unless authorized?
    haml :index
  end

  get "/logout" do
    logout
    redirect "/"
  end
end
