require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'POST /wordlists response', type: :request do
  include TokenHelper

  describe 'when request is valid' do
    before :each do
      @token = generate_token(SecureRandom.uuid)
      headers = {
        'Authorization' => "Bearer #{@token}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      expect(Wordlist.count).to be(0)
      post '/wordlists', headers: headers
    end

    it 'is 201 status' do
      expect(response).to have_http_status(201)
    end

    it 'has correct body' do
      expect(Wordlist.count).to be(1)
      expected_created_at = JSON.parse(Wordlist.first.created_at.to_json)
      expected_body = {
        data: {
          attributes: {
            created_at: expected_created_at
          },
          id: Wordlist.first.id,
          token: @token,
          type: 'wordlist'
        }
      }

      actual_body = JSON.parse(response.body).deep_symbolize_keys
      expect(actual_body).to eq(expected_body)
    end
  end
end
