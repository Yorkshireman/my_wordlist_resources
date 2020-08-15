require 'securerandom'

FactoryBot.define do
  factory :wordlist do
    user_id { SecureRandom.uuid }
  end
end
