module Api
  module V1
    class SalesController < Api::BaseController
      before_action :set_business
      before_action :authorize_owner!

      # GET /api/v1/businesses/:business_id/sales
      def index
        sales = @business.orders.delivered.includes(order_items: :product).order(updated_at: :desc)

        sales = sales.where("updated_at >= ?", params[:from]) if params[:from].present?
        sales = sales.where("updated_at <= ?", params[:to]) if params[:to].present?

        render json: {
          total_revenue: sales.sum(:total).to_f,
          count: sales.count,
          sales: sales.map { |o| sale_json(o) }
        }
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

      def sale_json(order)
        {
          id: order.id,
          customer: order.user.name,
          total: order.total.to_f,
          delivered_at: order.updated_at,
          items: order.order_items.map { |i| { name: i.product.name, quantity: i.quantity } }
        }
      end
    end
  end
end
