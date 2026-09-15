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
        resources :orders, only: [ :create ]
        resources :orders, only: [ :index ], controller: "business_orders" do
          member do
            patch :update_status
          end
        end

        resource :dashboard, only: [ :show ], controller: "dashboard"
        resources :sales, only: [ :index ]
        resources :inventory, only: [ :index, :update ]
      end

      resources :products, only: [ :show, :update, :destroy ]

      resources :orders, only: [ :index, :show ] do
        member do
          patch :add_item
          patch :confirm
          patch :cancel
        end
      end

      namespace :admin do
        resources :businesses, only: [ :index ] do
          member do
            patch :approve
            patch :suspend
            patch :reactivate
          end
        end

        resources :users, only: [ :index, :show ] do
          member do
            patch :toggle_active
          end
        end

        resources :orders, only: [ :index, :show ]

        resource :stats, only: [ :show ], controller: "stats"
      end
    end
  end
end
