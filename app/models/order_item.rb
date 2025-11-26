class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  def line_total
    price.to_f * quantity.to_i
  end
end
