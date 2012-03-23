class ChordProPS < ChordProFile
  extension "ps"

  processor do |chordpro, ps|
    txt = ChordProTXT.new(chordpro)
    system("chordii -o #{ps.path} #{txt.path}")
  end
end
