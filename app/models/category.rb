class Category < ApplicationRecord
  self.implicit_order_column = 'created_at'
  has_and_belongs_to_many :wordlist_entries
  has_many :words, through: :wordlist_entries
  validates :name, presence: true
  validates_uniqueness_of :name
end
