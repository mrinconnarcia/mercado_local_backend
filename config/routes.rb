Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'health', to: 'health#show'

      post 'auth/register', to: 'auth#register'
      post 'auth/login', to: 'auth#login'

      get 'me', to: 'sessions#show'
      delete 'logout', to: 'sessions#destroy'
    end
  end
end
