module Api
  module V1
    class BusinessHoursController < Api::BaseController
      skip_before_action :authenticate_request, only: [ :index ]

      before_action :set_business
      before_action :authorize_owner!, only: [ :update_all ]

      # GET /api/v1/businesses/:business_id/business_hours
      def index
        hours = @business.business_hours.order(:day_of_week)
        render json: hours.map { |h| hour_json(h) }
      end

      # PUT /api/v1/businesses/:business_id/business_hours
      # Reemplaza los 7 días de una sola vez, como una planilla semanal
      def update_all
        ActiveRecord::Base.transaction do
          hours_params.each do |day_params|
            hour = @business.business_hours.find_or_initialize_by(day_of_week: day_params[:day_of_week])
            hour.update!(day_params.except(:day_of_week))
          end
        end

        render json: @business.business_hours.order(:day_of_week).map { |h| hour_json(h) }
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: [ e.message ] }, status: :unprocessable_entity
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

      def hours_params
        params.require(:business_hours).map do |h|
          h.permit(:day_of_week, :opens_at, :closes_at, :closed)
        end
      end

      def hour_json(hour)
        {
          day_of_week: hour.day_of_week,
          day_name: hour.day_name,
          opens_at: hour.opens_at&.strftime("%H:%M"),
          closes_at: hour.closes_at&.strftime("%H:%M"),
          closed: hour.closed
        }
      end
    end
  end
end
