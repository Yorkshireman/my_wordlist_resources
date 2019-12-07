class Wordlist < ApplicationRecord
  self.implicit_order_column = 'created_at'
  has_many :wordlist_entries
  has_many :words, through: :wordlist_entries
  validates :user_id, presence: true
end
