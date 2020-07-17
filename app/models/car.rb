class Car < ApplicationRecord
  belongs_to :category
  belongs_to :wordlist_entry
  # validates_uniqueness_of :category_id
end
