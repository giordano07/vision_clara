Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :products, only: [:index]
  resources :budgets, only: [:new, :create]

  # Defines the root path route ("/")
  root "pages#home"

  get '/create_admin', to: proc { 
    AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
    [200, {}, ['Admin created']]
  }

  
  # Rutas amigables para categorías y subcategorías
  get ':category', to: 'products#index', as: :category, constraints: { category: /ninos|damas|caballeros/ }
  get ':category/:subcategory', to: 'products#index', as: :category_subcategory, constraints: { 
    category: /ninos|damas|caballeros/,
    subcategory: /lentes-de-sol|lentes-recetados|clip-on/
  }
end
