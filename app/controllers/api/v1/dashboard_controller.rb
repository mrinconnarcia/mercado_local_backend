module Api
  module V1
    class DashboardController < Api::BaseController
      before_action :set_business
      before_action :authorize_owner!

      # GET /api/v1/businesses/:business_id/dashboard
      def show
        orders = @business.orders

        render json: {
          business: business_summary,
          orders: {
            pending: orders.pending.count,
            accepted: orders.accepted.count,
            preparing: orders.preparing.count,
            ready: orders.ready.count,
            delivered: orders.delivered.count,
            cancelled: orders.cancelled.count,
            total: orders.count
          },
          products: {
            total: @business.products.count,
            available: @business.products.visible.count,
            out_of_stock: @business.products.where(stock: 0).count
          },
          sales: {
            total_revenue: orders.delivered.sum(:total).to_f,
            orders_delivered: orders.delivered.count
          }
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

      def business_summary
        {
          id: @business.id,
          name: @business.name,
          status: @business.status,
          active: @business.active,
          category: @business.category.name,
          address: @business.address,
          phone: @business.phone
        }
      end
    end
  end
end
