class OrderProcessor
  class InsufficientStock < StandardError; end

  def self.accept!(order)
    ActiveRecord::Base.transaction do
      order.order_items.includes(:product).each do |item|
        product = Product.lock.find(item.product_id)

        if product.stock < item.quantity
          raise InsufficientStock, "Stock insuficiente de #{product.name} (quedan #{product.stock})"
        end

        product.update!(stock: product.stock - item.quantity)
        product.update!(available: false) if product.stock.zero?
      end

      order.update!(status: :accepted)
    end

    order
  end

  def self.restore_stock!(order)
    ActiveRecord::Base.transaction do
      order.order_items.includes(:product).each do |item|
        product = Product.lock.find(item.product_id)
        product.update!(stock: product.stock + item.quantity)
      end
    end
  end
end
