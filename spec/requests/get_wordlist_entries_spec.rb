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

  WordlistEntry.create(word_id: @word2.id, wordlist_id: @wordlist_id, description: 'the process of decaying')
end

RSpec.describe 'GET /wordlist_entries response', type: :request do
  include TokenHelper

  describe 'when request is valid' do
    before :each do
      Wordlist.destroy_all
      Word.destroy_all
      WordlistEntry.destroy_all
      create_wordlist
      token = generate_token(@user_id, @wordlist_id)
      headers = {
        'Authorization' => "Bearer #{token}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      create_wordlist_entries
      get '/wordlist_entries', headers: headers
      @token = JWT.encode(
        { user_id: @user_id, wordlist_id: @wordlist_id },
        ENV['JWT_SECRET_KEY'],
        'HS256'
      )

      @wordlist_entries = Wordlist.find(@wordlist_id).wordlist_entries
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
                word: {
                  id: @word2.id,
                  name: 'rot',
                  wordlist_ids: [@wordlist_id]
                },
                created_at: JSON.parse(@wordlist_entries[1].created_at.to_json),
                description: 'the process of decaying'
              },
              id: @wordlist_entries[1].id
            },
            {
              attributes: {
                word: {
                  id: @word.id,
                  name: 'capable',
                  wordlist_ids: [@wordlist_id]
                },
                created_at: JSON.parse(@wordlist_entries[0].created_at.to_json),
                description: 'having the ability, fitness, or quality necessary to do or achieve a specified thing'
              },
              id: @wordlist_entries[0].id
            }
          ]
        }
      }

      actual_body = JSON.parse(response.body).deep_symbolize_keys
      expect(actual_body).to eq(expected_body)
    end
  end
end
