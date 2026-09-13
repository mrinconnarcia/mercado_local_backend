module Api
  module V1
    class ProductsController < Api::BaseController
      skip_before_action :authenticate_request, only: [:index, :show]

      before_action :set_business, only: [:index, :create]
      before_action :set_product, only: [:show, :update, :destroy]
      before_action :authorize_owner!, only: [:create, :update, :destroy]

      # GET /api/v1/businesses/:business_id/products
      def index
        products = @business.products
        products = products.visible unless owner_or_admin?
        render json: products.map { |p| product_json(p) }
      end

      # GET /api/v1/products/:id
      def show
        render json: product_json(@product)
      end

      # POST /api/v1/businesses/:business_id/products
      def create
        product = @business.products.new(product_params)

        if product.save
          render json: product_json(product), status: :created
        else
          render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/products/:id
      def update
        if @product.update(product_params)
          render json: product_json(@product)
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product.destroy
        head :no_content
      end

      private

      def set_business
        @business = Business.find(params[:business_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Negocio no encontrado' }, status: :not_found
      end

      def set_product
        @product = Product.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Producto no encontrado' }, status: :not_found
      end

      def authorize_owner!
        business = @business || @product.business
        return if business.user_id == current_user.id || current_user.admin?

        render json: { error: 'No tenés permisos sobre este producto' }, status: :forbidden
      end

      def owner_or_admin?
        current_user.present? && (current_user.id == @business.user_id || current_user.admin?)
      end

      def product_params
        params.require(:product).permit(:name, :description, :price, :available, :stock, :image)
      end

      def product_json(product)
        {
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price.to_f,
          available: product.available,
          in_stock: product.in_stock?,
          stock: product.stock,
          business_id: product.business_id,
          image_url: product.image.attached? ? url_for(product.image) : nil
        }
      end
    end
  end
end