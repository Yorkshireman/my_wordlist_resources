class Wordlist < ApplicationRecord
  self.implicit_order_column = 'created_at'
  validates :user_id, presence: true
end
