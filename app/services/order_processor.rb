class OrderProcessor
  class InsufficientStock < StandardError; end

  def self.accept!(order)
    ActiveRecord::Base.transaction do
      order.order_items.includes(:product).each do |item|
        product = Product.lock.find(item.product_id)

        if product.stock < item.quantity
          raise InsufficientStock, "Stock insuficiente de #{product.name} (quedan #{product.stock})"
        end

        new_stock = product.stock - item.quantity
        # update_columns escribe stock/available sin correr las validaciones
        # del resto del modelo (price, image_url, etc.), que no tienen nada
        # que ver con aceptar el pedido.
        product.update_columns(
          stock: new_stock,
          available: new_stock.positive?
        )
      end

      order.update!(status: :accepted)
    end

    order
  end

  def self.restore_stock!(order)
    ActiveRecord::Base.transaction do
      order.order_items.includes(:product).each do |item|
        product = Product.lock.find(item.product_id)
        product.update_columns(
          stock: product.stock + item.quantity,
          available: true
        )
      end
    end
  end
end
