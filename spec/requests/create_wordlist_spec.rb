require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'POST /wordlists response', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  include TokenHelper

  describe 'when request is valid' do
    before :each do
      Wordlist.destroy_all
      @user_id = SecureRandom.uuid
      token = generate_token(@user_id)
      headers = {
        'Authorization' => "Bearer #{token}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      freeze_time do
        time_now = Time.now
        post '/wordlists', headers: headers
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

    it 'is 201 status' do
      expect(response).to have_http_status(201)
    end

    it 'has correct body' do
      expected_body = {
        data: {
          token: @time_frozen_token,
          type: 'wordlist',
          attributes: {}
        }
      }

      actual_body = JSON.parse(response.body).deep_symbolize_keys
      expect(actual_body).to eq(expected_body)
    end
  end
end