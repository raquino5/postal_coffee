module TaxTable
  RATES = {
    "MB" => { gst: 0.05, pst: 0.07, hst: 0.0 },
    "ON" => { gst: 0.0,  pst: 0.0,  hst: 0.13 },
    "BC" => { gst: 0.05, pst: 0.07, hst: 0.0 },
    "QC" => { gst: 0.05, pst: 0.09975, hst: 0.0 },
    "SK" => { gst: 0.05, pst: 0.06, hst: 0.0 },
  }.freeze

  def self.for(province)
    RATES[province] || { gst: 0.05, pst: 0.0, hst: 0.0 }
  end
end
