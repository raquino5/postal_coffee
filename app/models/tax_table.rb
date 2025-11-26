module TaxTable
  RATES = {
    "MB" => { gst: 0.05, pst: 0.07, hst: 0.0 },
    "ON" => { gst: 0.0,  pst: 0.0,  hst: 0.13 },
    "BC" => { gst: 0.05, pst: 0.07, hst: 0.0 },
    "QC" => { gst: 0.05, pst: 0.09975, hst: 0.0 },
    "SK" => { gst: 0.05, pst: 0.06, hst: 0.0 },
  }.freeze

  def self.for(province_code)
    province = Province.find_by(code: province_code)

    if province
      {
        gst: province.gst.to_f,
        pst: province.pst.to_f,
        hst: province.hst.to_f
      }
    else
      { gst: 0.05, pst: 0.0, hst: 0.0 }
    end
  end
end
