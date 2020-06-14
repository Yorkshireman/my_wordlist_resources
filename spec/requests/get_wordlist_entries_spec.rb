require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

def create_wordlist
  @user_id = SecureRandom.uuid
  @wordlist_id = Wordlist.create(user_id: @user_id).id
end

def create_wordlist_entries
  @word = Word.create(name: 'capable')
  @word2 = Word.create(name: 'rot')
  WordlistEntry.create(
    word_id: @word.id,
    wordlist_id: @wordlist_id,
    description: 'having the ability, fitness, or quality necessary to do or achieve a specified thing'
  )
  sleep(0.1)
  WordlistEntry.create(word_id: @word2.id, wordlist_id: @wordlist_id, description: 'the process of decaying')
end

RSpec.describe 'GET /wordlist_entries response', type: :request do
  include TokenHelper

  context 'when request is valid' do
    before :each do
      Wordlist.destroy_all
      Word.destroy_all
      WordlistEntry.destroy_all
      create_wordlist
      token = generate_token(@user_id)
      headers = {
        'Authorization' => "Bearer #{token}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      create_wordlist_entries
      get '/wordlist_entries', headers: headers, params: { wordlist_id: @wordlist_id, format: :json }
      @token = JWT.encode(
        { user_id: @user_id },
        ENV['JWT_SECRET_KEY'],
        'HS256'
      )

      @wordlist_entries_created_at = Wordlist.find(@wordlist_id).wordlist_entries.map(&:created_at)
    end

    it 'is 200 status' do
      expect(response).to have_http_status(200)
    end

    it 'has correct body' do
      expected_body = {
        data: {
          token: @token,
          wordlist_entries: [
            {
              attributes: {
                created_at: JSON.parse(@wordlist_entries_created_at[1].to_json),
                description: 'the process of decaying',
                word: {
                  id: @word2.id,
                  name: 'rot',
                  wordlist_ids: [@wordlist_id]
                },
                wordlist_id: @wordlist_id
              },
              id: Wordlist.find(@wordlist_id).wordlist_entries[1].id
            },
            {
              attributes: {
                created_at: JSON.parse(@wordlist_entries_created_at[0].to_json),
                description: 'having the ability, fitness, or quality necessary to do or achieve a specified thing',
                word: {
                  id: @word.id,
                  name: 'capable',
                  wordlist_ids: [@wordlist_id]
                },
                wordlist_id: @wordlist_id
              },
              id: Wordlist.find(@wordlist_id).wordlist_entries[0].id
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

      it 'returns 401' do
        expect(response).to have_http_status(401)
      end

      it 'error message is appropriate' do
        expected_message = 'missing Authorization header'
        actual_message = JSON.parse(response.body).deep_symbolize_keys[:errors][0][:title]
        expect(actual_message).to eq(expected_message)
      end
    end
  end
end
