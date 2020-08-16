require 'ffaker'
require 'securerandom'

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| FFaker::Lorem.word + n.to_s }
  end

  factory :word do
    sequence(:name) { |n| FFaker::Lorem.word + n.to_s }
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
  end

  factory :wordlist_entry_with_categories, class: WordlistEntry do
    description { FFaker::Lorem.unique.phrase }
    word_id { create(:word).id }
    wordlist

    after :create do |wordlist_entry|
      3.times { wordlist_entry.categories << create(:category) }
    end
  end
end

def wordlist_with_wordlist_entries_with_categories(wordlist_entries_count: 2)
  FactoryBot.create(:wordlist) do |wordlist|
    FactoryBot.create_list(:wordlist_entry_with_categories, wordlist_entries_count, wordlist: wordlist)
  end
end

def wordlist_with_wordlist_entries_no_categories(wordlist_entries_count: 2)
  FactoryBot.create(:wordlist) do |wordlist|
    FactoryBot.create_list(:wordlist_entry, wordlist_entries_count, wordlist: wordlist)
  end
end
