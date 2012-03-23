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

  def initialize(chordpro)
    @name = "#{chordpro.name}#{extension}"
    @file = generate(chordpro)
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

  def generate(chordpro)
    tmp = Tempfile.new(name)
    processor.call(chordpro, tmp) unless processor.nil?
    tmp
  end
end
