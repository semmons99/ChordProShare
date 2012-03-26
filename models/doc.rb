require "rest_client"

class Doc < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :name
  validates_uniqueness_of :name, scope: :user_id

  def render
    RestClient.post(
      "http://tenbyten.com/cgi-bin/webchord.pl",
      chordpro: markup
    ).gsub("WebChordOut.css", "/stylesheets/WebChordOut.css")
  end
end
