Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :movies, only: [:index]
      resources :movie_years, only: [:index]
    end
  end
end
