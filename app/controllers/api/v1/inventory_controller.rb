module Api
  module V1
    class InventoryController < Api::BaseController
      before_action :set_business
      before_action :authorize_owner!

      # GET /api/v1/businesses/:business_id/inventory
      def index
        products = @business.products.order(:name)
        render json: products.map { |p| inventory_json(p) }
      end

      # PATCH /api/v1/businesses/:business_id/inventory/:product_id
      def update
        product = @business.products.find(params[:id])

        if product.update(inventory_params)
          render json: inventory_json(product)
        else
          render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Producto no encontrado" }, status: :not_found
      end

      private

      def set_business
        @business = Business.find(params[:business_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Negocio no encontrado" }, status: :not_found
      end

      def authorize_owner!
        return if @business.user_id == current_user.id || current_user.admin?

        render json: { error: "No tenés permisos sobre este negocio" }, status: :forbidden
      end

      def inventory_params
        params.require(:product).permit(:stock, :available)
      end

      def inventory_json(product)
        {
          id: product.id,
          name: product.name,
          stock: product.stock,
          available: product.available,
          in_stock: product.in_stock?
        }
      end
    end
  end
end
