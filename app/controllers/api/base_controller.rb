module Api
  class BaseController < ApplicationController
    before_action :authenticate_request

    attr_reader :current_user

    def paginated_response(scope, serializer)
      per_page = (params[:per_page] || 25).to_i
      per_page = 25 if per_page <= 0

      pagy_obj, records = pagy(:offset, scope, limit: per_page)

      {
        data: records.map { |r| serializer.call(r) },
        meta: {
          page: pagy_obj.page,
          pages: pagy_obj.pages,
          count: pagy_obj.count,
          per_page: pagy_obj.limit
        }
      }
    end

    private

    def authenticate_request
      header = request.headers["Authorization"]
      unless header.present?
        return render json: { error: "No autorizado: Falta el header Authorization" }, status: :unauthorized
      end

      token = header.split(" ").last

      begin
        decoded = JsonWebToken.decode(token)
      rescue JWT::DecodeError, JWT::ExpiredSignature => e
        return render json: { error: "Token inválido o expirado (#{e.message})" }, status: :unauthorized
      rescue StandardError => e
        return render json: { error: "Error interno al validar token: #{e.message}" }, status: :unauthorized
      end

      if decoded && (@current_user = User.find_by(id: decoded[:user_id]))
        return
      end

      render json: { error: "No autorizado: Usuario no encontrado para este token" }, status: :unauthorized
    end

    def authorize_role!(*roles)
      unless roles.map(&:to_s).include?(current_user.role)
        render json: { error: "No tenés permisos para esta acción" }, status: :forbidden
      end
    end
  end
end
