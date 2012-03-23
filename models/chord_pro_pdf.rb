class ChordProPDF < ChordProFile
  extension "pdf"

  processor do |chordpro, pdf|
    ps = ChordProPS.new(chordpro)
    system("ps2pdf #{ps.path} #{pdf.path}")
  end
end
