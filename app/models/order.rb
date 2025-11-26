class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy

  def full_tax_total
    total_gst.to_f + total_pst.to_f + total_hst.to_f
  end
end
