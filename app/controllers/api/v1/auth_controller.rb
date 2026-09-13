module Api
  module V1
    class AuthController < ApplicationController
      def register
        user = User.new(user_params)
        user.role ||= :customer

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
            return render json: { error: 'Cuenta desactivada' }, status: :forbidden
          end
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token, user: user_response(user) }, status: :ok
        else
          render json: { error: 'Email o contraseña inválidos' }, status: :unauthorized
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :name, :role)
      end


      def user_response(user)
        { id: user.id, email: user.email, name: user.name, role: user.role }
      end
    end
  end
end
