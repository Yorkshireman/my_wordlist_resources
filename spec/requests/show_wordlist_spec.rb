require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'GET /wordlist response', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  include TokenHelper

  describe 'when request is valid' do
    before :each do
      Wordlist.destroy_all
      @user_id = SecureRandom.uuid
      @wordlist_id = Wordlist.create(user_id: @user_id).id
      token = generate_token(@user_id, @wordlist_id)
      headers = {
        'Authorization' => "Bearer #{token}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      get '/wordlist', headers: headers
      @token = JWT.encode(
        {
          exp: (1_590_331_503 + 1800).to_i,
          user_id: @user_id,
          wordlist_id: @wordlist_id
        },
        ENV['JWT_SECRET_KEY'],
        'HS256'
      )
    end

    it 'is 200 status' do
      expect(response).to have_http_status(200)
    end

    it 'has correct body' do
      expected_body = {
        data: {
          token: @token,
          type: 'wordlist',
          attributes: {}
        }
      }

      actual_body = JSON.parse(response.body).deep_symbolize_keys
      expect(actual_body).to eq(expected_body)
    end

    describe 'when request token does not include wordlist_id' do
      before :each do
        @user_id = SecureRandom.uuid
        @wordlist_id = Wordlist.create(user_id: @user_id).id
        token = generate_token(@user_id)
        headers = {
          'Authorization' => "Bearer #{token}",
          'CONTENT_TYPE' => 'application/vnd.api+json'
        }

        get '/wordlist', headers: headers
        @token = JWT.encode(
          {
            exp: (1_590_331_503 + 1800).to_i,
            user_id: @user_id,
            wordlist_id: @wordlist_id
          },
          ENV['JWT_SECRET_KEY'],
          'HS256'
        )
      end

      it 'returned token includes wordlist_id' do
        actual_token = JSON.parse(response.body).deep_symbolize_keys[:data][:token]
        expect(actual_token).to eq(@token)
      end
    end
  end
end
