class Word < ApplicationRecord
  has_many :wordlist_entries
  has_many :wordlists, through: :wordlist_entries
  validates :name, presence: true
end
