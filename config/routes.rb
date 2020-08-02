Rails.application.routes.draw do
  get 'wordlist',   to: 'wordlists#show'
  post 'wordlists', to: 'wordlists#create'
  resources :wordlist_entries, only: [:index, :create] do
    resources :categories, only: [:create]
  end
end
