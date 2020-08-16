require 'jwt'
require 'rails_helper'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'GET /wordlist response', type: :request do
  include TokenHelper

  describe 'when request is valid' do
    let(:wordlist) { create(:wordlist) }

    before :each do
      headers = {
        'Authorization' => "Bearer #{generate_token(wordlist.user_id)}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      get '/wordlist', headers: headers
    end

    it 'is 200 status' do
      expect(response).to have_http_status(200)
    end

    it 'has correct body' do
      actual_body = JSON.parse(response.body).deep_symbolize_keys
      expected_body = {
        data: {
          attributes: {
            created_at: JSON.parse(wordlist.created_at.to_json)
          },
          id: wordlist.id,
          token: generate_token(wordlist.user_id),
          type: 'wordlist'
        }
      }

      expect(actual_body).to eq(expected_body)
    end
  end
end
