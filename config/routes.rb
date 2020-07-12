Rails.application.routes.draw do
  get 'wordlist',                                                       to: 'wordlists#show'
  get 'wordlist_entries',                                               to: 'wordlist_entries#index'
  post 'wordlist_entries/:wordlist_entry_id/relationships/categories',  to: 'wordlist_entries_categories#create'
  post 'wordlists',                                                     to: 'wordlists#create'
  post 'wordlist_entries',                                              to: 'wordlist_entries#create'
end
