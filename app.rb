require "sinatra"
require "haml"
require "active_record"

require "logger"

Dir.glob("models/*"){|model| require_relative model}

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

    def errors
      session[:errors] ||= []
    end

    def flush_errors
      session[:errors] = []
    end

    def register_errors(messages)
      messages = *messages

      session[:errors] ||= []
      session[:errors] += messages
    end
  end

  before do
    unless request.path_info =~ /^\/(login|logout|register)$/
      redirect to("/login") unless authorized?
    end

    if request.path_info =~ /^\/(preview|download|render)$/
      @chordpro = ChordPro.new(params[:markup], params[:docname])
    end 

    flush_errors
  end

  get "/" do
    haml :index, locals: {docs: current_user.docs}
  end

  get "/edit/:docname" do
    docname = params[:docname]
    doc     = current_user.docs.find_by_name(docname)

    if doc.nil?
      register_errors("Could not find requested Document")
      haml :index, locals: {docs: current_user.docs}
    else
      haml :edit, locals: {doc: doc}
    end
  end

  get "/edit" do
    haml :edit, locals: {doc: Doc.new}
  end

  post "/preview" do
    @chordpro.render
  end

  post "/download" do
    txt = ChordProTXT.new(@chordpro)

    send_file(txt.path, filename: txt.name, type: "text/plain")
  end

  post "/render" do
    pdf = ChordProPDF.new(@chordpro)

    send_file(pdf.path, filename: pdf.name, type: "application/pdf")
  end

  post "/save" do
    docname = params[:docname]
    markup  = params[:markup]

    doc = current_user.docs.find_or_create_by_name(docname)
    doc.markup = markup

    register_errors(doc.errors.full_messages) unless doc.save

    haml :edit, locals: {doc: doc}
  end

  post "/rename" do
    oldname = params[:oldname]
    newname = params[:newname]

    doc = current_user.docs.find_by_name(oldname)

    if doc.nil?
      register_errors("Could not find requested Document")
      haml :edit
    end

    if doc.update_attributes(name: newname)
      haml :edit, locals: {doc: doc}
    else
      register_errors(doc.errors.full_messages)
      doc.name = oldname
      haml :edit, locals: {doc: doc}
    end
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
      register_errors("Invalid Email/Password")
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
      register_errors(user.errors)
      haml :register
    end
  end
end
