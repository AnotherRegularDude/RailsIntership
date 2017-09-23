Rails.application.routes.draw do
  root 'publishing_houses#index'

  resources :publishing_houses do
    resources :books
  end
end
