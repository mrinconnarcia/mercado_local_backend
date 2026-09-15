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
