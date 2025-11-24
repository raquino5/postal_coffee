class Page < ApplicationRecord
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      title
      slug
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
