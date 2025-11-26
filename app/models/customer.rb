class Customer < ApplicationRecord
  has_many :orders

  validates :first_name, :last_name, :email, :province, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      first_name
      last_name
      email
      address
      city
      province
      postal_code
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      orders
    ]
  end
end
