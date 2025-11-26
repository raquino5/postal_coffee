class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy

  def full_tax_total
    total_gst.to_f + total_pst.to_f + total_hst.to_f
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      customer_id
      status
      subtotal
      total
      total_gst
      total_hst
      total_pst
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      customer
      order_items
    ]
  end
end
