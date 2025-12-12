Rails.application.routes.draw do
  # ============================================================================
  # AUTHENTICATION ROUTES (Rails built-in authentication)
  # ============================================================================
  resource :session          # Login/logout
  resources :passwords, param: :token  # Password reset

  # ============================================================================
  # HEALTH CHECK
  # ============================================================================
  get "up" => "rails/health#show", as: :rails_health_check

  # ============================================================================
  # PUBLIC SITE ROUTES (Homepage)
  # ============================================================================

  # Homepage
  root "home#index"

  # Sports & Fitness
  resources :sports, only: [ :index, :show ]

  # Reading List
  resources :books, only: [ :index ]

  # Gear & Equipment
  resources :gear_items, only: [ :index ], path: "gear", as: :gear

  # Projects Showcase
  resources :projects, only: [ :index, :show ]

  # Blog
  get "blog", to: "blog_posts#index", as: :blog
  get "blog/:slug", to: "blog_posts#show", as: :blog_post

  # ============================================================================
  # ADMIN PANEL ROUTES (Protected - requires authentication)
  # Path: /admin/*
  # ============================================================================
  namespace :admin do
    root "dashboard#index"  # Admin dashboard homepage

    # Content Management - Full CRUD
    resources :sport_activities
    resources :books do
      member do
        delete :purge_cover_image
      end
    end
    resources :gear_items do
      member do
        delete :purge_product_image
      end
    end
    resources :projects
    resources :blog_posts do
      member do
        patch :publish
        patch :unpublish
      end
    end
    resources :social_links
  end
end
