module Api
  class BaseController < ApplicationController
    before_action :authenticate_request

    attr_reader :current_user

    private

    def authenticate_request
      header = request.headers['Authorization']
      token = header.split(' ').last if header

      decoded = token ? JsonWebToken.decode(token) : nil

      if decoded && (@current_user = User.find_by(id: decoded[:user_id]))
        return
      end

      render json: { error: 'No autorizado' }, status: :unauthorized
    end

    def authorize_role!(*roles)
      unless roles.map(&:to_s).include?(current_user.role)
        render json: { error: 'No tenés permisos para esta acción' }, status: :forbidden
      end
    end
  end
end