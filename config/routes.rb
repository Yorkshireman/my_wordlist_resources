Rails.application.routes.draw do
  get 'wordlist',           to: 'wordlists#show'
  get 'wordlist_entries',   to: 'wordlist_entries#index'
  post 'wordlists',         to: 'wordlists#create'
end
