require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'GET /wordlist_entries response', type: :request do
  include TokenHelper

  context 'when request is valid' do
    before :each do
      @wordlist = wordlist_with_wordlist_entries
      @token = generate_token(@wordlist.user_id)
      headers = {
        'Authorization' => "Bearer #{@token}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      get '/wordlist_entries', headers: headers
    end

    it 'is 200 status' do
      expect(response).to have_http_status(200)
    end

    it 'has correct body' do
      category1 = @wordlist.wordlist_entries.first.categories.first
      category2 = @wordlist.wordlist_entries.second.categories.first
      wordlist_entries_created_at = @wordlist.wordlist_entries.map(&:created_at)

      expected_body = {
        data: {
          token: @token,
          wordlist_entries: [
            {
              attributes: {
                categories: [{ id: category2.id, name: category2.name }],
                created_at: JSON.parse(wordlist_entries_created_at[1].to_json),
                description: @wordlist.wordlist_entries.second.description,
                word: {
                  id: @wordlist.wordlist_entries.second.word.id,
                  name: @wordlist.wordlist_entries.second.word.name,
                  wordlist_ids: [@wordlist.id]
                },
                wordlist_id: @wordlist.id
              },
              id: @wordlist.wordlist_entries.second.id
            },
            {
              attributes: {
                categories: [{ id: category1.id, name: category1.name }],
                created_at: JSON.parse(wordlist_entries_created_at[0].to_json),
                description: @wordlist.wordlist_entries.first.description,
                word: {
                  id: @wordlist.wordlist_entries.first.word.id,
                  name: @wordlist.wordlist_entries.first.word.name,
                  wordlist_ids: [@wordlist.id]
                },
                wordlist_id: @wordlist.id
              },
              id: @wordlist.wordlist_entries.first.id
            }
          ]
        }
      }

      actual_body = JSON.parse(response.body).deep_symbolize_keys
      expect(actual_body).to eq(expected_body)
    end

    it 'WordlistEntries are correctly ordered by created_at (most recent first)' do
      actual_body = JSON.parse(response.body).deep_symbolize_keys
      first_wordlist_entry_date = actual_body[:data][:wordlist_entries][0][:attributes][:created_at]
      second_wordlist_entry_date = actual_body[:data][:wordlist_entries][1][:attributes][:created_at]
      expect(first_wordlist_entry_date > second_wordlist_entry_date).to be(true)
    end
  end

  context 'when request is not valid' do
    context 'when Authorization header is missing' do
      before :each do
        get '/wordlist_entries'
      end

      it 'returns 400' do
        expect(response).to have_http_status(400)
      end

      it 'error message is appropriate' do
        expected_message = 'missing Authorization header'
        actual_message = JSON.parse(response.body).deep_symbolize_keys[:errors][0][:title]
        expect(actual_message).to eq(expected_message)
      end
    end
  end
end
