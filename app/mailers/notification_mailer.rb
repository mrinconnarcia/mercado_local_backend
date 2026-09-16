class NotificationMailer < ApplicationMailer
  default from: "Mercado Local <no-reply@mercadolocal.com>"

  def notify(notification)
    @notification = notification
    @user = notification.user

    mail(to: @user.email, subject: notification.title)
  end
end
