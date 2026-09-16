module Api
  module V1
    module Admin
      class BusinessesController < Admin::BaseController
        before_action :set_business, only: [ :approve, :suspend, :reactivate ]

        # GET /api/v1/admin/businesses?status=pending
        def index
          businesses = Business.includes(:category, :user).order(created_at: :desc)
          businesses = businesses.where(status: params[:status]) if params[:status].present?

          # render json: businesses.map { |b| business_json(b) }
          render json: paginated_response(businesses, ->(b) { business_json(b) })
        end

        # PATCH /api/v1/admin/businesses/:id/approve
        def approve
          @business.update!(status: :approved)
          Notifier.notify(user: @business.user, type: "business_approved", notifiable: @business)
          render json: business_json(@business)
        end

        def suspend
          @business.update!(status: :suspended)
          Notifier.notify(user: @business.user, type: "business_suspended", notifiable: @business)
          render json: business_json(@business)
        end

        # PATCH /api/v1/admin/businesses/:id/reactivate
        def reactivate
          @business.update!(status: :approved)
          render json: business_json(@business)
        end

        private

        def set_business
          @business = Business.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Negocio no encontrado" }, status: :not_found
        end

        def business_json(business)
          {
            id: business.id,
            name: business.name,
            status: business.status,
            active: business.active,
            category: business.category.name,
            address: business.address,
            owner: { id: business.user.id, name: business.user.name, email: business.user.email },
            created_at: business.created_at
          }
        end
      end
    end
  end
end
