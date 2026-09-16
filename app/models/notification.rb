class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :title, presence: true
  validates :notification_type, presence: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
end
