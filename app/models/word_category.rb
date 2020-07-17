class WordCategory < ApplicationRecord
  belongs_to :category
  belongs_to :wordlist_entry
end
