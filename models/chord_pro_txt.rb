class ChordProTXT < ChordProFile
  extension "txt"

  processor do |doc, txt|
    txt.write(doc.markup)
    txt.close
  end
end
