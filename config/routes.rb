Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'authentication#login'
      post 'auth/register', to: 'authentication#register'
      get 'auth/me', to: 'authentication#me'

      resources :users, only: [:index, :show, :update]
      resources :teams do
        resources :teams do
          resources :projects, except: [:new, :edit] do
            resources :tasks, execept: [:new, :edit] do
              resources :comments, except: [:new, :edit, :show]
            end
          end
        end
        member do
          post :add_member
          delete :remove_member
        end
      end
    end
  end
end
