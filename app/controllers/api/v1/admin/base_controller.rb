module Api
  module V1
    module Admin
      class BaseController < Api::BaseController
        before_action :require_admin!

        private

        def require_admin!
          return if current_user.admin?

          render json: { error: "Acceso restringido a administradores" }, status: :forbidden
        end
      end
    end
  end
end
