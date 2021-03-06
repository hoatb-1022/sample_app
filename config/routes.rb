Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root "static_pages#home"

    get "/static_pages/home"
    get "/static_pages/help"

    get "/signup", to: "users#new"
    post "/signup", to: "users#create"

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    get ":id/following", to: "following#index", as: "following"
    get ":id/followers", to: "followers#index", as: "followers"

    resources :users, except: :new
    resources :account_activations, only: :edit
    resources :password_resets, except: [:index, :destroy]
    resources :microposts, only: [:create, :destroy]
    resources :relationships, only: [:create, :destroy]
  end
end
