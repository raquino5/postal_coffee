# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image
  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      name
      description
      price
      on_sale
      is_active
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      category
    ]
  end
end
