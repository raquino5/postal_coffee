# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image
  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end
