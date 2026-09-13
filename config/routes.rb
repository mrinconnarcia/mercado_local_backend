Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"

      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"

      get "me", to: "sessions#show"
      delete "logout", to: "sessions#destroy"

      resources :categories, only: [ :index ]

      resources :businesses, only: [ :index, :show, :create, :update ] do
        member do
          patch :toggle_active
        end
        resources :products, only: [ :index, :create ]
        resources :orders, only: [ :index ], controller: "business_orders" do
          member do
            patch :update_status
          end
        end
        resources :orders, only: [ :create ]
      end

      resources :products, only: [ :show, :update, :destroy ]

      resources :orders, only: [ :index, :show ] do
        member do
          patch :add_item
          patch :confirm
          patch :cancel
        end
      end
    end
  end
end
