require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'GET /wordlist response', type: :request do
  include TokenHelper

  describe 'when request is valid' do
    before :each do
      Wordlist.destroy_all
      user_id = SecureRandom.uuid
      @wordlist = Wordlist.create(user_id: user_id)
      token = generate_token(user_id)
      headers = {
        'Authorization' => "Bearer #{token}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      get '/wordlist', headers: headers
      @token = JWT.encode(
        { user_id: user_id },
        ENV['JWT_SECRET_KEY'],
        'HS256'
      )
    end

    it 'is 200 status' do
      expect(response).to have_http_status(200)
    end

    it 'has correct body' do
      expected_created_at = JSON.parse(@wordlist.created_at.to_json)
      expected_body = {
        data: {
          attributes: {
            created_at: expected_created_at
          },
          id: @wordlist.id,
          token: @token,
          type: 'wordlist'
        }
      }

      actual_body = JSON.parse(response.body).deep_symbolize_keys
      expect(actual_body).to eq(expected_body)
    end
  end
end
