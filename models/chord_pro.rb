require "rest_client"

class ChordPro
  attr_reader :markup, :name

  def initialize(markup, name)
    @markup = markup
    @name   = name
    @name   = "chordpro" if name.nil? || name.strip == ""
  end

  def render
    RestClient.post(
      "http://tenbyten.com/cgi-bin/webchord.pl",
      chordpro: markup
    )
  end
end
