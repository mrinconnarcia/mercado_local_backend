module Api
  module V1
    class BusinessOrdersController < Api::BaseController
      before_action :set_business
      before_action :authorize_owner!
      before_action :set_order, only: [ :update_status ]

      # GET /api/v1/businesses/:business_id/orders
      def index
        orders = @business.orders.includes(order_items: :product).order(created_at: :desc)
        orders = orders.where(status: params[:status]) if params[:status].present?
        render json: orders.map { |o| order_json(o) }
      end

      # PATCH /api/v1/businesses/:business_id/orders/:id/update_status
      def update_status
        new_status = params[:status]

        unless @order.can_transition_to?(new_status)
          return render json: {
            error: "No se puede pasar de '#{@order.status}' a '#{new_status}'"
          }, status: :unprocessable_entity
        end

        case new_status
        when "accepted"
          OrderProcessor.accept!(@order)
        when "cancelled"
          OrderProcessor.restore_stock!(@order) unless @order.pending?
          @order.update!(status: :cancelled)
        else
          @order.update!(status: new_status)
        end

        render json: order_json(@order, detailed: true)
      rescue OrderProcessor::InsufficientStock => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def set_business
        @business = Business.find(params[:business_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Negocio no encontrado" }, status: :not_found
      end

      def set_order
        @order = @business.orders.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Pedido no encontrado" }, status: :not_found
      end

      def authorize_owner!
        return if @business.user_id == current_user.id || current_user.admin?

        render json: { error: "No tenés permisos sobre este negocio" }, status: :forbidden
      end

      def order_json(order, detailed: false)
        base = {
          id: order.id,
          status: order.status,
          total: order.total.to_f,
          customer: order.user.name,
          created_at: order.created_at
        }
        return base unless detailed

        base.merge(
          items: order.order_items.map do |item|
            { name: item.product.name, quantity: item.quantity, unit_price: item.unit_price.to_f }
          end
        )
      end
    end
  end
end
