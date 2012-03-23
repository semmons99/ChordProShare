require "sinatra"
require "haml"
require "active_record"
require "rest_client"

require "logger"
require "tempfile"

require_relative "models/user"
require_relative "models/doc"
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
    markup = params[:markup]

    render_chordpro_preview(markup)
  end

  post "/download" do
    markup  = params[:markup]
    docname = params[:docname]

    send_chordpro_file(markup, docname)
  end

  post "/render" do
    markup  = params[:markup]
    docname = params[:docname]

    send_chordpro_pdf(markup, docname)
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

  private

  def render_chordpro_preview(markup)
    RestClient.post(
      "http://tenbyten.com/cgi-bin/webchord.pl",
      chordpro: markup
    )
  end

  def send_chordpro_file(markup, docname)
    chordpro = create_temp_chordpro(markup)

    docname = "chordpro" if docname.nil? || docname.strip == ""
    send_file chordpro.path, filename: "#{docname}.txt", type: "text/plain"
  end

  def send_chordpro_pdf(markup, docname)
    chordpro = create_temp_chordpro(markup)
    pdf      = create_temp_pdf(chordpro)

    docname = "chordpro" if docname.nil? || docname.strip == ""
    send_file pdf.path, filename: "#{docname}.pdf", type: "application/pdf"
  end

  def create_temp_chordpro(markup)
    chordpro = Tempfile.new("chordpro")
    chordpro.write(markup)
    chordpro.close
    chordpro
  end

  def create_temp_pdf(chordpro)
    ps  = Tempfile.new("ps")
    pdf = Tempfile.new("pdf")

    system("chordii -o #{ps.path} #{chordpro.path}")
    system("ps2pdf #{ps.path} #{pdf.path}")

    pdf
  end
end
