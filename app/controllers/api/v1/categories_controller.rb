module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        render json: Category.all.order(:name).as_json(only: [:id, :name, :slug])
      end
    end
  end
end