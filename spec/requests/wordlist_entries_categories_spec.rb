require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'POST /wordlist_entries/:wordlist_entry_id/relationships/categories response', type: :request, focus: true do
  include TokenHelper
  let(:category_id) { SecureRandom.uuid }
  let(:category_name) { 'noun' }
  let(:user_id) { SecureRandom.uuid }
  let(:token) { generate_token(user_id) }
  let(:headers) do
    {
      'Authorization' => "Bearer #{token}",
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end
  let(:word) { Word.create(name: 'table') }
  let(:wordlist) { Wordlist.create(user_id: user_id) }
  let(:wordlist_entry) { WordlistEntry.create(word_id: word.id, wordlist_id: wordlist.id) }

  before :each do
    params = {
      categories: [
        { id: category_id, name: category_name }
      ]
    }

    post "/wordlist_entries/#{wordlist_entry.id}/relationships/categories", params: params.to_json, headers: headers
  end

  it 'adds a Category to a WordlistEntry' do # improve test name
    expect(wordlist_entry.categories.first.id).to eq(category_id)
    expect(wordlist_entry.categories.first.name).to eq(category_name)
  end

  it 'is 201 status' do
    expect(response).to have_http_status(201)
  end

  it 'has correct body' do
    expected_body = {
      data: {
        type: 'wordlist-entry',
        id: wordlist_entry.id,
        attributes: {
          categories: [
            { id: category_id, name: category_name }
          ]
        }
      }
    }

    actual_body = JSON.parse(response.body).deep_symbolize_keys
    expect(actual_body).to eq(expected_body)
  end
end
