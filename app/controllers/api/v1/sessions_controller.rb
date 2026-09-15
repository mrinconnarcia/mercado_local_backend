module Api
  module V1
    class SessionsController < Api::BaseController
      def show
        render json: {
          id: current_user.id,
          email: current_user.email,
          name: current_user.name,
          role: current_user.role
        }
      end

      def destroy
        # Con JWT stateless no hay sesión en el servidor para "matar".
        # El logout real lo hace el cliente (Ember) borrando el token guardado.
        # Acá dejamos el endpoint por consistencia de API y para logs/auditoría futura.
        render json: { message: "Sesión cerrada" }, status: :ok
      end
    end
  end
end
