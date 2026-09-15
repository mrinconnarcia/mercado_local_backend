module Api
  module V1
    module Admin
      class OrdersController < Admin::BaseController
        # GET /api/v1/admin/orders?status=pending&business_id=1
        def index
          orders = Order.includes(:user, :business).order(created_at: :desc)
          orders = orders.where(status: params[:status]) if params[:status].present?
          orders = orders.where(business_id: params[:business_id]) if params[:business_id].present?

          render json: orders.limit(200).map { |o| order_json(o) }
        end

        # GET /api/v1/admin/orders/:id
        def show
          order = Order.includes(order_items: :product).find(params[:id])
          render json: order_json(order, detailed: true)
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Pedido no encontrado' }, status: :not_found
        end

        private

        def order_json(order, detailed: false)
          base = {
            id: order.id,
            status: order.status,
            total: order.total.to_f,
            customer: { id: order.user.id, name: order.user.name },
            business: { id: order.business.id, name: order.business.name },
            created_at: order.created_at
          }
          return base unless detailed

          base.merge(
            items: order.order_items.map do |i|
              { name: i.product.name, quantity: i.quantity, unit_price: i.unit_price.to_f }
            end
          )
        end
      end
    end
  end
end