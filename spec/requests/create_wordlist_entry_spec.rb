require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'POST /wordlistentries response', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  include TokenHelper

  describe 'when request is valid' do
    before :each do
      @user_id = SecureRandom.uuid
      @wordlist = Wordlist.create(user_id: @user_id)
      token = generate_token(@user_id, @wordlist.id)
      headers = {
        'Authorization' => "Bearer #{token}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      freeze_time do
        time_now = Time.now
        post '/wordlistentries', headers: headers
        @time_frozen_token = JWT.encode(
          {
            exp: (time_now + 1800).to_i,
            user_id: @user_id,
            wordlist_id: @wordlist.id
          },
          ENV['JWT_SECRET_KEY'],
          'HS256'
        )
      end
    end

    it 'is 201 status' do
      expect(response).to have_http_status(201)
    end

    it 'has correct body' do
      expected_body = {
        data: {
          token: @time_frozen_token,
          type: 'wordlist',
          attributes: {
            entries: [
              {
                word: 'dog',
                description: 'A hairy animal of varying size.'
              }
            ]
          }
        }
      }

      actual_body = JSON.parse(response.body).deep_symbolize_keys
      expect(actual_body).to eq(expected_body)
    end
  end
end
