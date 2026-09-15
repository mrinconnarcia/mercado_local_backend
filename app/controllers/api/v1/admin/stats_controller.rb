module Api
  module V1
    module Admin
      class StatsController < Admin::BaseController
        # GET /api/v1/admin/stats
        def show
          render json: {
            users: {
              total: User.count,
              customers: User.customer.count,
              business_owners: User.business_owner.count,
              admins: User.admin.count,
              inactive: User.where(active: false).count
            },
            businesses: {
              total: Business.count,
              pending: Business.pending.count,
              approved: Business.approved.count,
              suspended: Business.suspended.count
            },
            products: {
              total: Product.count,
              out_of_stock: Product.where(stock: 0).count
            },
            orders: {
              total: Order.count,
              pending: Order.pending.count,
              in_progress: Order.where(status: [:accepted, :preparing, :ready]).count,
              delivered: Order.delivered.count,
              cancelled: Order.cancelled.count
            },
            revenue: {
              total: Order.delivered.sum(:total).to_f,
              last_30_days: Order.delivered.where('updated_at >= ?', 30.days.ago).sum(:total).to_f
            }
          }
        end
      end
    end
  end
end