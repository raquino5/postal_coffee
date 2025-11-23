Rails.application.routes.draw do
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
  resources :products, only: [:index, :show]
  # Categories: show products in a category
  resources :categories, only: [:show]
end
