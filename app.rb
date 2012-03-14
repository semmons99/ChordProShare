require "sinatra"
require "active_record"
require "logger"

require_relative "models/user"
ActiveRecord::Base.logger = Logger.new(STDOUT)

class ChordProShare < Sinatra::Base
  require_relative "config/database.rb"

  enable :sessions

  helpers do
    def authorized?
      !session[:user].nil?
    end

    def user
      session[:user]
    end
  end

  get "/" do
    redirect to("/login") unless authorized?
    haml :index
  end

  get "/login" do
    haml :login
  end

  post "/login" do
    user = User.find_by_email(params[:email])

    if !user.nil? && user.valid_password?(params[:password])
      session[:user] = user
      redirect to("/")
    else
      @errors = ActiveModel::Errors.new(Object.new)
      @errors[:base] << "Invalid Email/Password"
      haml :login
    end
  end

  get "/logout" do
    session[:user] = nil
    redirect to("/")
  end

  get "/register" do
    haml :register
  end

  post "/register" do
    user = User.new(
      email:                 params[:email],
      password:              params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if user.save
      session[:user] = user
      redirect to("/")
    else
      @errors = user.errors
      haml :register
    end
  end
end
