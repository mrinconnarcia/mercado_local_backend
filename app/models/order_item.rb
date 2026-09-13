class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  before_validation :set_unit_price, on: :create

  private

  def set_unit_price
    self.unit_price = product.price if product && unit_price.blank?
  end
end