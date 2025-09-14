Rails.application.routes.draw do
  get 'pages/show'
  resources :posts, only: %i[index show]
  resources :pages, only: :show
  resource :session
  resources :passwords, param: :token

  # Management interface
  namespace :manage do
    root 'gutter_press#index'
    resources :posts
    resources :pages
    resources :links, only: :index
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # SEO sitemap
  get 'sitemap.xml' => 'sitemap#show', defaults: { format: 'xml' }, as: :sitemap

  # Atom feed
  get 'feed.xml' => 'feeds#show', defaults: { format: 'xml' }, as: :feed

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root 'posts#index'
end
