require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'GET /wordlist_entries response', type: :request do
  include TokenHelper

  context 'when request is valid' do
    let(:wordlist) { wordlist_with_wordlist_entries_with_categories }

    before :each do
      headers = {
        'Authorization' => "Bearer #{generate_token(wordlist.user_id)}",
        'CONTENT_TYPE' => 'application/vnd.api+json'
      }

      get '/wordlist_entries', headers: headers
    end

    it 'is 200 status' do
      expect(response).to have_http_status(200)
    end

    describe 'response body' do
      let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }
      let(:first_wordlist_entry) { response_body[:data][:wordlist_entries][0] }
      let(:second_wordlist_entry) { response_body[:data][:wordlist_entries][1] }

      it 'has token' do
        expect(response_body[:data][:token]).to eq(generate_token(wordlist.user_id))
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
        let(:expected_first_wordlist_entry) { wordlist.wordlist_entries.second }

        it 'has correct id' do
          expect(first_wordlist_entry[:id]).to eq(expected_first_wordlist_entry.id)
        end

        it 'has correct categories in name order' do
          expected_categories =
            JSON.parse(expected_first_wordlist_entry.categories.order(:name).to_json(only: [:id, :name]))
                .map(&:deep_symbolize_keys)

          expect(first_wordlist_entry[:attributes][:categories]).to eq(expected_categories)
        end

        it 'has created_at' do
          expect(first_wordlist_entry[:attributes][:created_at]).to be_truthy
        end

        it 'has correct description' do
          expect(first_wordlist_entry[:attributes][:description]).to eq(expected_first_wordlist_entry.description)
        end

        it 'has correct word id' do
          expect(first_wordlist_entry[:attributes][:word][:id]).to eq(expected_first_wordlist_entry.word.id)
        end

        it 'has correct word name' do
          expect(first_wordlist_entry[:attributes][:word][:name]).to eq(expected_first_wordlist_entry.word.name)
        end

        it 'wordlist_ids is an array of 1' do
          expect(first_wordlist_entry[:attributes][:word][:wordlist_ids].length).to be(1)
        end

        it 'has correct wordlist_ids' do
          expect(first_wordlist_entry[:attributes][:word][:wordlist_ids][0])
            .to eq(expected_first_wordlist_entry.word.wordlist_ids.first)
        end

        it 'has correct wordlist_id' do
          expect(first_wordlist_entry[:attributes][:wordlist_id]).to eq(expected_first_wordlist_entry.wordlist_id)
        end
      end

      describe 'second wordlist_entry' do
        let(:expected_second_wordlist_entry) { wordlist.wordlist_entries.first }

        it 'has correct id' do
          expect(second_wordlist_entry[:id]).to eq(expected_second_wordlist_entry.id)
        end

        it 'has correct categories in name order' do
          expected_categories =
            JSON.parse(expected_second_wordlist_entry.categories.order(:name).to_json(only: [:id, :name]))
                .map(&:deep_symbolize_keys)

          expect(second_wordlist_entry[:attributes][:categories]).to eq(expected_categories)
        end

        it 'has created_at' do
          expect(second_wordlist_entry[:attributes][:created_at]).to be_truthy
        end

        it 'has correct description' do
          expect(second_wordlist_entry[:attributes][:description]).to eq(expected_second_wordlist_entry.description)
        end

        it 'has correct word id' do
          expect(second_wordlist_entry[:attributes][:word][:id]).to eq(expected_second_wordlist_entry.word.id)
        end

        it 'has correct word name' do
          expect(second_wordlist_entry[:attributes][:word][:name]).to eq(expected_second_wordlist_entry.word.name)
        end

        it 'wordlist_ids is an array of 1' do
          expect(second_wordlist_entry[:attributes][:word][:wordlist_ids].length).to be(1)
        end

        it 'has correct wordlist_ids' do
          expect(second_wordlist_entry[:attributes][:word][:wordlist_ids][0])
            .to eq(expected_second_wordlist_entry.word.wordlist_ids.first)
        end

        it 'has correct wordlist_id' do
          expect(second_wordlist_entry[:attributes][:wordlist_id]).to eq(expected_second_wordlist_entry.wordlist_id)
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
        actual_message = JSON.parse(response.body).deep_symbolize_keys[:errors][0][:title]
        expect(actual_message).to eq('missing Authorization header')
      end
    end
  end
end
