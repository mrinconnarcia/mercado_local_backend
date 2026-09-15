class Product < ApplicationRecord
  belongs_to :business
  has_one_attached :image
  has_many :order_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :visible, -> { where(available: true) }

  def in_stock?
    stock > 0
  end
end
