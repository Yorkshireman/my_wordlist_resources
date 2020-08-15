require 'ffaker'
require 'securerandom'

FactoryBot.define do
  factory :wordlist do
    user_id { SecureRandom.uuid }
  end

  factory :word do
    name { FFaker::Lorem.unique.word }
  end

  factory :wordlist_entry do
    description { FFaker::Lorem.unique.phrase }
    word_id { create(:word).id }
    wordlist
  end
end

def wordlist_with_wordlist_entries(wordlist_entries_count: 2)
  FactoryBot.create(:wordlist) do |wordlist|
    FactoryBot.create_list(:wordlist_entry, wordlist_entries_count, wordlist: wordlist)
  end
end
