class User < ApplicationRecord
  has_secure_password
  has_many :businesses, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :notifications, dependent: :destroy
  has_many :reviews, dependent: :destroy

  enum :role, customer: 0, business_owner: 1, admin: 2

  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  before_validation { self.email = email.downcase.strip if email.present? }
end
