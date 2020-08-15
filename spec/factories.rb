require 'securerandom'

FactoryBot.define do
  factory :wordlist do
    user_id { SecureRandom.uuid }
  end

  factory :word do
    name { 'factory_bot_word_name' }
  end

  factory :wordlist_entry do
    word_id { create(:word).id }
    wordlist_id { create(:wordlist).id }
  end
end
