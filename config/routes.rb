Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :movies, only: [:index, :show]
      resources :movies_years, only: [:index]
    end
  end
end
