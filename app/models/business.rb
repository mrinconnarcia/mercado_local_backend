class Business < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error

  enum :status, pending: 0, approved: 1, suspended: 2

  validates :name, presence: true
  validates :address, presence: true

  scope :visible, -> { where(active: true, status: :approved) }

  before_validation :set_owner_as_business_owner, on: :create

  private

  def set_owner_as_business_owner
    user&.business_owner! unless user&.business_owner? || user&.admin?
  end
end
