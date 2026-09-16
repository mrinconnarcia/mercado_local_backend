module Api
  module V1
    class NotificationsController < Api::BaseController
      # GET /api/v1/notifications
      def index
        notifications = current_user.notifications.recent
        notifications = notifications.unread if params[:unread] == "true"

        render json: {
          unread_count: current_user.notifications.unread.count,
          notifications: notifications.limit(50).map { |n| notification_json(n) }
        }
      end

      # PATCH /api/v1/notifications/:id/read
      def mark_read
        notification = current_user.notifications.find(params[:id])
        notification.update!(read: true)
        render json: notification_json(notification)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Notificación no encontrada" }, status: :not_found
      end

      # PATCH /api/v1/notifications/read_all
      def mark_all_read
        current_user.notifications.unread.update_all(read: true, updated_at: Time.current)
        render json: { message: "Todas marcadas como leídas", unread_count: 0 }
      end

      private

      def notification_json(notification)
        {
          id: notification.id,
          title: notification.title,
          body: notification.body,
          type: notification.notification_type,
          read: notification.read,
          notifiable_type: notification.notifiable_type,
          notifiable_id: notification.notifiable_id,
          created_at: notification.created_at
        }
      end
    end
  end
end
