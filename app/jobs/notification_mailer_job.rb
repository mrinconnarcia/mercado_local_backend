class NotificationMailerJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification

    NotificationMailer.notify(notification).deliver_now
  end
end
