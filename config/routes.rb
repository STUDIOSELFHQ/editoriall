Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]
  resource :registration, only: %i[new create]
  resources :joins, only: :create

  resources :desks, only: %i[index show new create] do
    resources :pieces, only: %i[new create]
    resources :agents, only: %i[create]
    resources :memberships, only: %i[create destroy]
  end

  resources :pieces, only: %i[show update] do
    resource :chair, only: :create
    resources :marks, only: %i[create update]
    resources :passes, only: :create do
      member do
        post :apply
        post :reject
      end
    end
  end

  root "pages#home"
end
