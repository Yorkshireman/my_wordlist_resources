require 'rails_helper'
require_relative '../../app/helpers/token_helper.rb'

RSpec.describe WordlistEntriesController do
  include ActiveSupport::Testing::TimeHelpers
  include TokenHelper

  describe 'when request is valid' do
    before :each do
      Wordlist.destroy_all
      WordlistEntry.destroy_all
      Word.destroy_all
      @user_id = SecureRandom.uuid
      @wordlist = Wordlist.create(user_id: @user_id).tap do |x|
        token = generate_token(@user_id, x.id)
        request.headers['Authorization'] = "Bearer #{token}"
      end

      # get RuntimeError Unknown Content-Type: application/vnd.api+json when using 'application/vnd.api+json'
      request.headers['CONTENT_TYPE'] = 'application/json'

      freeze_time do
        time_now = Time.now
        post :create, params: {
          wordlist_entry: {
            description: 'something to put things on',
            word: {
              name: 'table'
            }
          },
          format: :json
        }

        wordlist_id = Wordlist.first.id
        @time_frozen_token = JWT.encode(
          {
            exp: (time_now + 1800).to_i,
            user_id: @user_id,
            wordlist_id: wordlist_id
          },
          ENV['JWT_SECRET_KEY'],
          'HS256'
        )
      end
    end

    it 'responds with 201 http status' do
      expect(response).to have_http_status(201)
    end

    it 'creates a Word' do
      expect(Word.count).to eq(1)
    end

    it 'has correct body' do
      expected_body = {
        data: {
          id: WordlistEntry.first.id,
          token: @time_frozen_token,
          type: 'wordlist-entry',
          attributes: {
            description: 'something to put things on',
            word: {
              id: Word.first.id,
              name: 'table',
              wordlist_ids: [@wordlist.id]
            }
          }
        }
      }

      actual_body = JSON.parse(response.body).deep_symbolize_keys
      expect(actual_body).to eq(expected_body)
    end
  end
end
