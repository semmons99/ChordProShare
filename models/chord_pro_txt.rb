class ChordProTXT < ChordProFile
  extension "txt"

  processor do |chordpro, txt|
    txt.write(chordpro.markup)
    txt.close
  end
end
