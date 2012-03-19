require "sinatra"
require "active_record"
require "rest_client"
require "coffee-filter"

require "logger"
require "tempfile"

require_relative "models/user"
ActiveRecord::Base.logger = Logger.new(STDOUT)

class ChordProShare < Sinatra::Base
  require_relative "config/database.rb"

  enable :sessions

  helpers do
    def authorized?
      !current_user.nil?
    end

    def logout
      session[:user] = nil
    end

    def current_user
      User.find_by_id(session[:user])
    end

    def current_user=(user)
      session[:user] = user.id
    end
  end

  before do
    unless request.path_info =~ /^\/(login|logout|register)$/
      redirect to("/login") unless authorized?
    end
  end

  get "/" do
    haml :index
  end

  get "/new" do
    haml :new
  end

  post "/preview" do
    chordpro = params[:chordpro]

    render_chordpro_preview(chordpro)
  end

  post "/download" do
    chordpro = params[:chordpro]
    docname  = params[:docname]

    send_chordpro_file(chordpro, docname)
  end

  get "/login" do
    haml :login
  end

  post "/login" do
    user = User.find_by_email(params[:email])

    if !user.nil? && user.valid_password?(params[:password])
      self.current_user = user
      redirect to("/")
    else
      @errors = ActiveModel::Errors.new(Object.new)
      @errors[:base] << "Invalid Email/Password"
      haml :login
    end
  end

  get "/logout" do
    logout
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
      self.current_user = user
      redirect to("/")
    else
      @errors = user.errors
      haml :register
    end
  end

  private

  def render_chordpro_preview(chordpro)
    RestClient.post(
      "http://tenbyten.com/cgi-bin/webchord.pl",
      chordpro: chordpro
    )
  end

  def send_chordpro_file(chordpro, docname)
    file = Tempfile.new("chordpro")
    file.write(chordpro)
    file.close

    docname ||= "chordpro"
    send_file file.path, filename: "#{docname}.txt"
  end
end
