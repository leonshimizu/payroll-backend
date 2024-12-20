Rails.application.routes.draw do
  post "/signup", to: "users#create"
  post "/login", to: "sessions#create"

  resources :companies do
    resources :departments, only: [ :index, :create, :update, :destroy ]
    resources :employees, only: [ :index, :create, :show, :update, :destroy ] do
      post :import, on: :collection
    end
    resources :custom_columns, only: [ :index, :create, :update, :destroy ]
    resources :payroll_records, only: [ :index, :create, :update, :destroy ] do
      collection do
        post :bulk
      end
    end
  end
end
