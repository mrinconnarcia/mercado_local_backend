module Api
  module V1
    class AuthController < ApplicationController
      PUBLIC_ROLES = %w[customer business_owner].freeze

      def register
        user = User.new(user_params)

        requested_role = params.dig(:user, :role).presence || "customer"
        unless PUBLIC_ROLES.include?(requested_role)
          return render json: { error: "Rol inválido" }, status: :forbidden
        end
        user.role = requested_role

        if user.save
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token, user: user_response(user) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email]&.downcase&.strip)

        if user&.authenticate(params[:password])
          unless user.active?
            return render json: { error: "Cuenta desactivada" }, status: :forbidden
          end
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token, user: user_response(user) }, status: :ok
        else
          render json: { error: "Email o contraseña inválidos" }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/forgot_password
      def forgot_password
        user = User.find_by(email: params[:email]&.downcase&.strip)

        if user
          raw_token = SecureRandom.urlsafe_base64(32)
          user.update!(reset_password_token: Digest::SHA256.hexdigest(raw_token), reset_password_sent_at: Time.current)
          PasswordMailer.reset_instructions(user, raw_token).deliver_later
        end

        # Mismo mensaje exista o no el email — evita que alguien use este endpoint
        # para averiguar qué emails están registrados en tu sistema.
        render json: { message: "Si el email existe, te enviamos instrucciones para restablecer tu contraseña." }
      end

      # POST /api/v1/auth/reset_password
      def reset_password
        hashed = Digest::SHA256.hexdigest(params[:token].to_s)
        user = User.find_by(reset_password_token: hashed)

        if user.nil? || user.reset_password_sent_at < 1.hour.ago
          return render json: { error: "El enlace es inválido o expiró. Pedí uno nuevo." }, status: :unprocessable_entity
        end

        user.password = params[:password]
        user.reset_password_token = nil
        user.reset_password_sent_at = nil

        if user.save
          render json: { message: "Contraseña actualizada. Ya podés iniciar sesión." }
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :name)
      end

      def user_response(user)
        { id: user.id, email: user.email, name: user.name, role: user.role }
      end
    end
  end
end

# para crear un usuario se hace desde consola "rails console"
# User.create!(email: 'admin@mercadolocal.com', password: 'unaClaveFuerte123', name: 'Admin', role: :admin)
