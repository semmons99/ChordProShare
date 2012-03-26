class ChordProPDF < ChordProFile
  extension "pdf"

  processor do |doc, pdf|
    ps = ChordProPS.new(doc)
    system("ps2pdf #{ps.path} #{pdf.path}")
  end
end
