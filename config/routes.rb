Rails.application.routes.draw do
  get 'wordlist',   to: 'wordlists#show'
  post 'wordlists', to: 'wordlists#create'
end
