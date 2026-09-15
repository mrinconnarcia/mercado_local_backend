module Api
  module V1
    module Admin
      class UsersController < Admin::BaseController
        before_action :set_user, only: [ :show, :toggle_active ]

        # GET /api/v1/admin/users?role=business_owner&q=martin
        def index
          users = User.order(created_at: :desc)
          users = users.where(role: params[:role]) if params[:role].present?
          users = users.where("name ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?

          render json: users.map { |u| user_json(u) }
        end

        # GET /api/v1/admin/users/:id
        def show
          render json: user_json(@user, detailed: true)
        end

        # PATCH /api/v1/admin/users/:id/toggle_active
        def toggle_active
          if @user.id == current_user.id
            return render json: { error: "No podés desactivar tu propia cuenta" }, status: :unprocessable_entity
          end

          @user.update!(active: !@user.active)
          render json: user_json(@user)
        end

        private

        def set_user
          @user = User.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Usuario no encontrado" }, status: :not_found
        end

        def user_json(user, detailed: false)
          base = {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            active: user.active,
            created_at: user.created_at
          }
          return base unless detailed

          base.merge(
            businesses: user.businesses.map { |b| { id: b.id, name: b.name, status: b.status } },
            orders_count: user.orders.count
          )
        end
      end
    end
  end
end
