module Api
  module V1
    class ReviewsController < Api::BaseController
      skip_before_action :authenticate_request, only: [ :index ]

      # GET /api/v1/businesses/:business_id/reviews
      def index
        business = Business.find(params[:business_id])
        reviews = business.reviews.includes(:user).order(created_at: :desc)

        render json: {
          average_rating: business.average_rating,
          count: business.reviews_count,
          reviews: reviews.map { |r| review_json(r) }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Negocio no encontrado" }, status: :not_found
      end

      # POST /api/v1/orders/:order_id/review
      def create
        order = current_user.orders.find(params[:order_id])

        unless order.reviewable?
          return render json: { error: "Este pedido no se puede calificar" }, status: :unprocessable_entity
        end

        review = Review.new(
          order: order,
          user: current_user,
          business: order.business,
          rating: params[:rating],
          comment: params[:comment]
        )

        if review.save
          render json: review_json(review), status: :created
        else
          render json: { errors: review.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Pedido no encontrado" }, status: :not_found
      end

      private

      def review_json(review)
        {
          id: review.id,
          rating: review.rating,
          comment: review.comment,
          customer: review.user.name,
          created_at: review.created_at
        }
      end
    end
  end
end
