class Word < ApplicationRecord
  self.implicit_order_column = 'created_at'
  has_many :categories, through: :wordlist_entries
  has_many :wordlist_entries
  has_many :wordlists, through: :wordlist_entries
  validates :name, presence: true
  validates_uniqueness_of :name
end
