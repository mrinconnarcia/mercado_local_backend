Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#show'

      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'

      get 'me', to: 'sessions#show'
      delete 'logout', to: 'sessions#destroy'

      resources :categories, only: [:index]

      resources :businesses, only: [:index, :show, :create, :update] do
        member do
          patch :toggle_active
        end
        resources :products, only: [:index, :create]
      end

      resources :products, only: [:show, :update, :destroy]
    end
  end
end
