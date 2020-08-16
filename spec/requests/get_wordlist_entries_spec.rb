require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'GET /wordlist_entries response', type: :request, focus: true do
  include TokenHelper

  context 'when request is valid' do
    before :each do
      @wordlist = wordlist_with_wordlist_entries_with_categories
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

    describe 'response body' do
      let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }

      it 'has token' do
        expect(response_body[:data][:token]).to eq(@token)
      end

      it 'has correct number of wordlist_entries' do
        expect(response_body[:data][:wordlist_entries].count).to eq(2)
      end

      it 'WordlistEntries are correctly ordered by most recent first' do
        first_wordlist_entry_date = response_body[:data][:wordlist_entries][0][:attributes][:created_at]
        second_wordlist_entry_date = response_body[:data][:wordlist_entries][1][:attributes][:created_at]
        expect(first_wordlist_entry_date > second_wordlist_entry_date).to be(true)
      end

      describe 'first wordlist_entry' do
        let(:actual_wle) { response_body[:data][:wordlist_entries][0] }
        let(:expected_wle) { @wordlist.wordlist_entries.second }

        it 'has correct id' do
          expect(actual_wle[:id]).to eq(expected_wle.id)
        end

        it 'has correct categories' do
          expected_categories =
            JSON.parse(expected_wle.categories.order(:name).to_json(only: [:id, :name]))
                .map(&:deep_symbolize_keys)

          expect(actual_wle[:attributes][:categories]).to eq(expected_categories)
        end

        it 'has created_at' do
          expect(actual_wle[:attributes][:created_at]).to be_truthy
        end

        it 'has correct description' do
          expect(actual_wle[:attributes][:description]).to eq(expected_wle.description)
        end

        it 'has correct word id' do
          expect(actual_wle[:attributes][:word][:id]).to eq(expected_wle.word.id)
        end

        it 'has correct word name' do
          expect(actual_wle[:attributes][:word][:name]).to eq(expected_wle.word.name)
        end

        it 'wordlist_ids is an array of 1' do
          expect(actual_wle[:attributes][:word][:wordlist_ids].length).to be(1)
        end

        it 'has correct wordlist_ids' do
          expect(actual_wle[:attributes][:word][:wordlist_ids][0]).to eq(expected_wle.word.wordlist_ids.first)
        end

        it 'has correct wordlist_id' do
          expect(actual_wle[:attributes][:wordlist_id]).to eq(expected_wle.wordlist_id)
        end
      end

      describe 'second wordlist_entry' do
        let(:actual_wle) { response_body[:data][:wordlist_entries][1] }
        let(:expected_wle) { @wordlist.wordlist_entries.first }

        it 'has correct id' do
          expect(actual_wle[:id]).to eq(expected_wle.id)
        end

        it 'has correct categories' do
          expected_categories =
            JSON.parse(expected_wle.categories.order(:name).to_json(only: [:id, :name]))
                .map(&:deep_symbolize_keys)

          expect(actual_wle[:attributes][:categories]).to eq(expected_categories)
        end

        it 'has created_at' do
          expect(actual_wle[:attributes][:created_at]).to be_truthy
        end

        it 'has correct description' do
          expect(actual_wle[:attributes][:description]).to eq(expected_wle.description)
        end

        it 'has correct word id' do
          expect(actual_wle[:attributes][:word][:id]).to eq(expected_wle.word.id)
        end

        it 'has correct word name' do
          expect(actual_wle[:attributes][:word][:name]).to eq(expected_wle.word.name)
        end

        it 'wordlist_ids is an array of 1' do
          expect(actual_wle[:attributes][:word][:wordlist_ids].length).to be(1)
        end

        it 'has correct wordlist_ids' do
          expect(actual_wle[:attributes][:word][:wordlist_ids][0]).to eq(expected_wle.word.wordlist_ids.first)
        end

        it 'has correct wordlist_id' do
          expect(actual_wle[:attributes][:wordlist_id]).to eq(expected_wle.wordlist_id)
        end
      end
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
