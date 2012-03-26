class ChordProPS < ChordProFile
  extension "ps"

  processor do |doc, ps|
    txt = ChordProTXT.new(doc)
    system("chordii -o #{ps.path} #{txt.path}")
  end
end
