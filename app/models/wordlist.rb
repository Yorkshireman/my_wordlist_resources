class Wordlist < ApplicationRecord
  validates :user_id, presence: true
end
