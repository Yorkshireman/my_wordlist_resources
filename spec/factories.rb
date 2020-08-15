require 'ffaker'
require 'securerandom'

FactoryBot.define do
  factory :category do
    name { FFaker::Lorem.unique.word }
  end

  factory :word do
    name { FFaker::Lorem.unique.word }
  end

  factory :word_category do
    category
    wordlist_entry
  end

  factory :wordlist do
    user_id { SecureRandom.uuid }
  end

  factory :wordlist_entry do
    description { FFaker::Lorem.unique.phrase }
    word_id { create(:word).id }
    wordlist

    after :create do |wordlist_entry|
      create_list :word_category, 1, category: create(:category), wordlist_entry: wordlist_entry
    end
  end
end

def wordlist_with_wordlist_entries(wordlist_entries_count: 2)
  FactoryBot.create(:wordlist) do |wordlist|
    FactoryBot.create_list(:wordlist_entry, wordlist_entries_count, wordlist: wordlist)
  end
end
