Rails.application.routes.draw do
  post "/signup", to: "users#create"
  post "/login", to: "sessions#create"

  resources :companies do
    resources :departments, only: [ :index, :create, :update, :destroy ]
    resources :employees, only: [ :index, :create, :show, :update, :destroy ]
    resources :custom_columns, only: [ :index, :create, :update, :destroy ]
    resources :payroll_records, only: [ :index, :create, :update, :destroy ]
  end
end
