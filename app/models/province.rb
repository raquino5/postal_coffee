class Province < ApplicationRecord
  has_many :users

  def tax_rates
    {
      gst: gst.to_f,
      pst: pst.to_f,
      hst: hst.to_f
    }
  end
end
