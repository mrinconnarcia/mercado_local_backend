class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validate :enough_stock

  before_validation :set_unit_price, on: :create

  private

  def enough_stock
    return unless product

    unless product.available?
      errors.add(:base, "#{product.name} no está disponible")
      return
    end

    if quantity.to_i > product.stock
      errors.add(:base, "Solo quedan #{product.stock} unidades de #{product.name}")
    end
  end

  def set_unit_price
    self.unit_price = product.price if product && unit_price.blank?
  end
end
