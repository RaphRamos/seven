Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/administration', as: 'rails_admin'
  devise_for :admins
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "event#new"
  resources :event, only: [:new, :create] do
    collection do
      get  'busy_events'
      get  'temp_events'
      post 'create_temp_event'
      get  'timetable'
      get  'confirm_event'
      get  'new_calendar'
    end
  end

  resources :test

  resources :payment_notifications, only: [:create]

  get '/client_by_email', to: 'client#client_by_email'
  get '/admin_calendar', to: 'admin/event#calendar'
  get '/admin_events', to: 'admin/event#events'
  post '/admin_events', to: 'admin/event#update'
  get '/admin_timetable', to: 'admin/event#timetable'

end
