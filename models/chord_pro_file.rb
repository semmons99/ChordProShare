require "tempfile"

class ChordProFile
  def self.extension(ext)
    ext = ".#{ext}" unless ext =~ /^\./
    @extension = ext
  end

  def self.processor(&block)
    @processor = block
  end

  attr_reader :name

  def initialize(doc)
    name = doc.name
    name = "chordpro" if name.nil? || name.strip == ""

    @name = "#{name}#{extension}"
    @file = generate(doc)
  end

  def path
    @file.path
  end

  def extension
    self.class.instance_variable_get(:@extension)
  end

  def processor
    self.class.instance_variable_get(:@processor)
  end

  private

  def generate(doc)
    tmp = Tempfile.new(name)
    processor.call(doc, tmp) unless processor.nil?
    tmp
  end
end
