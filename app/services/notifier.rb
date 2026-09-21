class Notifier
  MESSAGES = {
    "new_order" => {
      title: "Nuevo pedido recibido",
      body: ->(order) { "Pedido ##{order.id} de #{order.user.name} por $#{order.total}" }
    },
    "accepted" => {
      title: "Tu pedido fue aceptado",
      body: ->(order) { "#{order.business.name} aceptó tu pedido ##{order.id}" }
    },
    "preparing" => {
      title: "Tu pedido se está preparando",
      body: ->(order) { "#{order.business.name} está preparando tu pedido ##{order.id}" }
    },
    "ready" => {
      title: "Tu pedido está listo",
      body: ->(order) { "Tu pedido ##{order.id} está listo para retirar en #{order.business.name}" }
    },
    "delivered" => {
      title: "Pedido entregado",
      body: ->(order) { "Tu pedido ##{order.id} fue entregado. ¡Gracias por tu compra!" }
    },
    "cancelled_by_business" => {
      title: "Tu pedido fue cancelado",
      body: ->(order) { "#{order.business.name} canceló el pedido ##{order.id}" }
    },
    "cancelled_by_customer" => {
      title: "Pedido cancelado por el cliente",
      body: ->(order) { "#{order.user.name} canceló el pedido ##{order.id}" }
    },
    "business_approved" => {
      title: "Tu negocio fue aprobado",
      body: ->(business) { "#{business.name} ya está publicado en Mercado Local" }
    },
    "business_suspended" => {
      title: "Tu negocio fue suspendido",
      body: ->(business) { "#{business.name} fue suspendido. Contactanos para más información." }
    },
    "new_business_pending" => {
      title: "Nuevo negocio esperando aprobación",
      body: ->(business) { "#{business.name} (#{business.user.name}) se registró y espera aprobación" }
    }
  }.freeze

  def self.notify(user:, type:, notifiable:, send_email: true)
    config = MESSAGES.fetch(type) { raise ArgumentError, "Tipo de notificación desconocido: #{type}" }

    notification = Notification.create!(
      user: user,
      title: config[:title],
      body: config[:body].call(notifiable),
      notification_type: type,
      notifiable: notifiable
    )

    NotificationMailerJob.perform_later(notification.id) if send_email

    notification
  rescue StandardError => e
    Rails.logger.error("Error al notificar (#{type}): #{e.message}")
    nil
  end
end
