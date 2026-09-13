class Category < ApplicationRecord
  has_many :businesses, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation { self.slug = name.parameterize if name.present? && slug.blank? }
end