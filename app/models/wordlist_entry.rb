class WordlistEntry < ApplicationRecord
  validates :word_id, presence: true
  validates :wordlist_id, presence: true
  belongs_to :word
  belongs_to :wordlist
end
