class WordlistEntry < ApplicationRecord
  self.implicit_order_column = 'created_at'
  validates :word_id, presence: true
  validates :wordlist_id, presence: true
  belongs_to :word
  belongs_to :wordlist
end
