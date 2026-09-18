class Order < ApplicationRecord
  belongs_to :user
  belongs_to :business
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_one :review, dependent: :destroy

  def confirmed?
    confirmed_at.present?
  end

  enum :status,
    pending: 0,
    accepted: 1,
    preparing: 2,
    ready: 3,
    delivered: 4,
    cancelled: 5

  VALID_TRANSITIONS = {
    "pending"   => %w[accepted cancelled],
    "accepted"  => %w[preparing cancelled],
    "preparing" => %w[ready cancelled],
    "ready"     => %w[delivered cancelled],
    "delivered" => [],
    "cancelled" => []
  }.freeze

  validates :total, numericality: { greater_than_or_equal_to: 0 }

  def can_transition_to?(new_status)
    VALID_TRANSITIONS.fetch(status, []).include?(new_status.to_s)
  end

  def recalculate_total!
    update!(total: order_items.sum { |item| item.quantity * item.unit_price })
  end

  def total_with_delivery
    (total || 0) + (delivery_fee || 0)
  end

  def reviewable?
    delivered? && review.nil?
  end
end
