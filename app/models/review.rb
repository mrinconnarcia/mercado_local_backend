class Review < ApplicationRecord
  belongs_to :order
  belongs_to :user
  belongs_to :business

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :order_id, uniqueness: { message: "ya tiene una reseña" }
  validate :order_must_be_delivered
  validate :user_must_own_order

  private

  def order_must_be_delivered
    return unless order

    errors.add(:base, "Solo podés calificar pedidos entregados") unless order.delivered?
  end

  def user_must_own_order
    return unless order && user

    errors.add(:base, "No podés calificar un pedido que no es tuyo") if order.user_id != user.id
  end
end
