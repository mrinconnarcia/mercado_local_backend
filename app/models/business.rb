class Business < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :business_hours, dependent: :destroy

  enum :status, pending: 0, approved: 1, suspended: 2

  validates :name, presence: true
  validates :address, presence: true

  scope :visible, -> { where(active: true, status: :approved) }

  before_validation :set_owner_as_business_owner, on: :create

  def open_now?
    hour = business_hours.find_by(day_of_week: Time.zone.now.wday)
    return false if hour.nil? || hour.closed?

    now = Time.zone.now.strftime("%H:%M:%S")
    now.between?(hour.opens_at.strftime("%H:%M:%S"), hour.closes_at.strftime("%H:%M:%S"))
  end

  private

  def set_owner_as_business_owner
    user&.business_owner! unless user&.business_owner? || user&.admin?
  end
end
