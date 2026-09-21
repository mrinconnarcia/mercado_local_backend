class PasswordMailer < ApplicationMailer
  def reset_instructions(user, raw_token)
    @user = user
    @reset_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:4000')}/reset-password?token=#{raw_token}"
    mail(to: user.email, subject: "Restablecé tu contraseña - Mercado Local")
  end
end
