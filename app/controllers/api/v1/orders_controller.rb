module Api
  module V1
    class OrdersController < Api::BaseController
      before_action :set_order, only: [ :show, :add_item, :confirm, :cancel ]
      before_action :authorize_customer!, only: [ :show, :add_item, :confirm, :cancel ]

      # GET /api/v1/orders  -> pedidos del cliente logueado
      def index
        orders = current_user.orders.includes(:business, order_items: :product).order(created_at: :desc)
        # render json: orders.map { |o| order_json(o) }
        render json: paginated_response(orders, ->(o) { order_json(o) })
      end

      # GET /api/v1/orders/:id
      def show
        render json: order_json(@order, detailed: true)
      end

      def create
        business = Business.find(params[:business_id])

        unless business.delivers_to?(params[:delivery_latitude], params[:delivery_longitude])
          return render json: { error: "Este negocio no realiza envíos a tu ubicación" }, status: :unprocessable_entity
        end

        order = current_user.orders.create!(
          business: business,
          status: :pending,
          total: 0,
          delivery_address: params[:delivery_address],
          delivery_latitude: params[:delivery_latitude],
          delivery_longitude: params[:delivery_longitude]
        )

        render json: order_json(order, detailed: true), status: :created
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Negocio no encontrado" }, status: :not_found
      end

      # POST /api/v1/orders/:id/add_item
      def add_item
        return render_not_editable unless @order.pending?

        product = @order.business.products.find(params[:product_id])
        item = @order.order_items.find_or_initialize_by(product: product)
        item.quantity = (item.quantity || 0) + params.fetch(:quantity, 1).to_i

        if item.save
          @order.recalculate_total!
          render json: order_json(@order, detailed: true)
        else
          render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Producto no encontrado en este negocio" }, status: :not_found
      end

      # PATCH /api/v1/orders/:id/confirm  -> el cliente confirma el carrito y lo envía al negocio
      def confirm
        return render_not_editable unless @order.pending?
        return render json: { error: "El carrito está vacío" }, status: :unprocessable_entity if @order.order_items.empty?

        if @order.confirmed?
          return render json: { error: "Este pedido ya fue confirmado" }, status: :unprocessable_entity
        end

        fee = @order.business.delivery_fee_for(@order.delivery_latitude, @order.delivery_longitude, @order.total)
        @order.update!(confirmed_at: Time.current, delivery_fee: fee)

        Notifier.notify(user: @order.business.user, type: "new_order", notifiable: @order)

        render json: order_json(@order, detailed: true)
      end


      def cancel
        unless @order.can_transition_to?("cancelled")
          return render json: { error: "Este pedido ya no se puede cancelar" }, status: :unprocessable_entity
        end

        OrderProcessor.restore_stock!(@order) unless @order.pending?
        @order.update!(status: :cancelled)

        Notifier.notify(
          user: @order.business.user,
          type: "cancelled_by_customer",
          notifiable: @order
        )

        render json: order_json(@order, detailed: true)
      end

      private

      def set_order
        @order = Order.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Pedido no encontrado" }, status: :not_found
      end

      def authorize_customer!
        return if @order.user_id == current_user.id || current_user.admin?

        render json: { error: "No tenés permisos sobre este pedido" }, status: :forbidden
      end

      def render_not_editable
        render json: { error: "Este pedido ya no admite cambios" }, status: :unprocessable_entity
      end

      def order_json(order, detailed: false)
        base = {
          id: order.id,
          status: order.status,
          total: order.total.to_f,
          delivery_fee: order.delivery_fee.to_f,
          total_with_delivery: order.total_with_delivery.to_f,
          business: order.business.name,
          created_at: order.created_at
        }
        return base unless detailed

        base.merge(
          items: order.order_items.map do |item|
            {
              product_id: item.product_id,
              name: item.product.name,
              quantity: item.quantity,
              unit_price: item.unit_price.to_f,
              subtotal: (item.quantity * item.unit_price).to_f
            }
          end
        )
      end
    end
  end
end
