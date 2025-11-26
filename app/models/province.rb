class Province < ApplicationRecord
  has_many :users

  def tax_rates
    {
      gst: gst.to_f,
      pst: pst.to_f,
      hst: hst.to_f
    }
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      id
      name
      code
      gst
      pst
      hst
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[
      users
    ]
  end
end
