Rails.application.routes.draw do
  devise_for :users
  get "categories/show"
  get "products/index"
  get "products/show"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "/about",   to: "pages#show", defaults: { slug: "about" }
  get "/contact", to: "pages#show", defaults: { slug: "contact" }
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # Front page: list of products
  root "products#index"
  # Products: index + show
  resources :products, only: [:index, :show] do
    collection do
      get :search
    end
  end

  resource :cart, only: [:show] do
    post   :add_item
    patch  :update_item
    delete :remove_item
  end

  resources :categories, only: [:show]
  resources :orders, only: [:new, :create, :show]
  get "my_orders", to: "orders#customer_orders", as: :my_orders

  resource :payments, only: [] do
    get :success
    get :cancel
  end
end
