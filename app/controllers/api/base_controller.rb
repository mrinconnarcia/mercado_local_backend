module Api
  class BaseController < ApplicationController
    before_action :authenticate_request

    attr_reader :current_user

    def paginated_response(scope, serializer)
      per_page = (params[:per_page] || 25).to_i
      per_page = 25 if per_page <= 0

      # En Pagy 43, la opción se llama 'limit' en lugar de 'items'
      pagy_obj, records = pagy(:offset, scope, limit: per_page)

      {
        data: records.map { |r| serializer.call(r) },
        meta: {
          page: pagy_obj.page,
          pages: pagy_obj.pages,
          count: pagy_obj.count,
          per_page: pagy_obj.limit # <- CAMBIO AQUÍ (antes era pagy_obj.items)
        }
      }
    end

    private

    def authenticate_request
      header = request.headers["Authorization"]
      token = header.split(" ").last if header

      decoded = token ? JsonWebToken.decode(token) : nil

      if decoded && (@current_user = User.find_by(id: decoded[:user_id]))
        return
      end

      render json: { error: "No autorizado" }, status: :unauthorized
    end

    def authorize_role!(*roles)
      unless roles.map(&:to_s).include?(current_user.role)
        render json: { error: "No tenés permisos para esta acción" }, status: :forbidden
      end
    end
  end
end
