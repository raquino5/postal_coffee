# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image
  has_many :product_tags, dependent: :destroy
  has_many :tags, through: :product_tags

  scope :active, -> { where(is_active: true) }
  scope :on_sale, -> { active.where(on_sale: true) }

  scope :new_products, -> { active.where('created_at >= ?', 3.days.ago) }

  scope :recently_updated, -> {
    active
      .where('updated_at >= ?', 3.days.ago)
      .where('created_at < ?', 3.days.ago)
  }

  validates :name, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def image_small
    image.variant(resize_to_fill: [200, 200]).processed
  end

  def image_medium
    image.variant(resize_to_fill: [400, 400]).processed
  end

  def image_large
    image.variant(resize_to_fit: [800, 800]).processed
  end

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
