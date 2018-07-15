Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/administration', as: 'rails_admin'
  devise_for :admins
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "event#new"
  resources :event, only: [:new, :create]
end
