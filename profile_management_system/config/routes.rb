Rails.application.routes.draw do

  get 'users/index'

  get 'users/login', to: 'users#get_login'

  post 'users/login', to: 'users#post_login'
  
  get 'users/get_profile', to: 'users#get_profile'

  resources :users, only: [:new, :create, :update, :edit]

  get 'admin', to: 'admin#get_login'

  post 'admin', to: 'admin#post_login'

  get 'admin/index', to: 'admin#index'

  post 'users/logout', to: 'users#logout'

  delete 'admin/logout', to: 'admin#logout'

  get 'admin/search_users', to: 'admin#search'
  post 'admin/search_users', to: 'admin#search'

  get 'admin/get_user', to: 'admin#get_user', :as => 'admin_get_user'

  get 'admin/edit_user', to: 'admin#edit_user', :as => 'admin_edit_user'

  put 'admin/edit_user', to: 'admin#update'
  patch 'admin/edit_user', to: 'admin#update'

  get 'admin/daily_reports', to: 'admin#daily_reports'

  delete 'admin/search', to: 'admin#change_status', :as => 'admin_change_status'

  get 'admin/create_user', to: 'admin#create_user_view', :as => 'admin_create_user_view'
  post 'admin/create_user', to: 'admin#create_user', :as => 'admin_create_user'

  #get 'userauthenticationfailed', to: 'users#authenticationfailed'
  root to: redirect('users/index')


  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  require 'sidekiq/cron/web'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  #post 'authenticate', to: 'authentication#authenticate'
end
