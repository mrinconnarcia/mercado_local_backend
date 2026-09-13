module Api
  module V1
    class BusinessesController < Api::BaseController
      skip_before_action :authenticate_request, only: [:index, :show]

      before_action :set_business, only: [:show, :update, :toggle_active]
      before_action :authorize_owner!, only: [:update, :toggle_active]

      # GET /api/v1/businesses
      def index
        businesses = Business.visible.includes(:category)
        businesses = businesses.where(category_id: params[:category_id]) if params[:category_id].present?
        businesses = businesses.where('name ILIKE ?', "%#{params[:q]}%") if params[:q].present?

        render json: businesses.map { |b| business_json(b) }
      end

      # GET /api/v1/businesses/:id
      def show
        render json: business_json(@business, detailed: true)
      end

      # POST /api/v1/businesses
      def create
        business = current_user.businesses.new(business_params)

        if business.save
          render json: business_json(business, detailed: true), status: :created
        else
          render json: { errors: business.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/businesses/:id
      def update
        if @business.update(business_params)
          render json: business_json(@business, detailed: true)
        else
          render json: { errors: @business.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/businesses/:id/toggle_active
      def toggle_active
        @business.update(active: !@business.active)
        render json: business_json(@business, detailed: true)
      end

      private

      def set_business
        @business = Business.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Negocio no encontrado' }, status: :not_found
      end

      def authorize_owner!
        return if @business.user_id == current_user.id || current_user.admin?

        render json: { error: 'No tenés permisos sobre este negocio' }, status: :forbidden
      end

      def business_params
        params.require(:business).permit(:name, :description, :address, :phone, :category_id)
      end

      def business_json(business, detailed: false)
        base = {
          id: business.id,
          name: business.name,
          address: business.address,
          category: business.category.name,
          active: business.active,
          status: business.status
        }
        return base unless detailed

        base.merge(
          description: business.description,
          phone: business.phone,
          owner_id: business.user_id
        )
      end
    end
  end
end