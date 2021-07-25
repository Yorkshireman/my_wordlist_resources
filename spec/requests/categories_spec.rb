require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper'

RSpec.describe 'POST /wordlist_entries/:wordlist_entry_id/categories', type: :request do
  include TokenHelper
  let(:user_id) { SecureRandom.uuid }
  let(:headers) do
    {
      'Authorization' => "Bearer #{generate_token(user_id)}",
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end

  context 'when the WordlistEntry has no categories yet' do
    let(:category_id) { SecureRandom.uuid }
    let(:category_name) { 'noun' }
    let(:params) do
      {
        categories: [
          { id: category_id, name: category_name }
        ]
      }
    end

    let(:wordlist) { wordlist_with_wordlist_entries_no_categories }
    let(:wordlist_entry) { wordlist.wordlist_entries.first }

    before :each do
      post "/wordlist_entries/#{wordlist_entry.id}/categories", params: params.to_json, headers: headers
    end

    it 'adds Category to WordlistEntry' do
      expect(wordlist_entry.categories.first.id).to eq(category_id)
      expect(wordlist_entry.categories.first.name).to eq(category_name)
    end

    it 'returns 201' do
      expect(response).to have_http_status(201)
    end

    describe 'body' do
      let(:body) { JSON.parse(response.body).deep_symbolize_keys }

      it 'has type' do
        expect(body[:data][:type]).to eq('wordlist-entry')
      end

      it 'has id' do
        expect(body[:data][:id]).to eq(wordlist_entry.id)
      end

      it 'has categories' do
        expect(body[:data][:attributes][:categories]).to eq(
          [{ id: category_id, name: category_name }]
        )
      end

      it 'has a token' do
        expect(body[:data][:token]).to eq(generate_token(user_id))
      end
    end
  end

  context 'when some categories already exist on the WordlistEntry' do
    let(:category) { create(:category) }
    let(:new_category_id) { SecureRandom.uuid }
    let(:new_category_name) { 'verb' }
    let(:params) do
      {
        categories: [
          { id: SecureRandom.uuid, name: category.name },
          { id: new_category_id, name: new_category_name }
        ]
      }
    end

    let(:wordlist_entry) { create(:wordlist_entry) }

    before :each do
      wordlist_entry.categories << category
      expect(wordlist_entry.categories.count).to eq(1)
      post "/wordlist_entries/#{wordlist_entry.id}/categories", params: params.to_json, headers: headers
    end

    it 'returns 201' do
      expect(response).to have_http_status(201)
    end

    it 'only new categories are added and existing one is not duplicated' do
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(wordlist_entry.categories.count).to eq(2)
      expect(body[:data][:attributes][:categories]).to eq(
        [
          { id: category.id, name: category.name },
          { id: new_category_id, name: new_category_name }
        ]
      )
    end
  end

  context 'when one of the two received categories already exists on a different WordlistEntry' do
    let(:category) { create(:category) }
    let(:new_category_id) { SecureRandom.uuid }
    let(:new_category_name) { 'verb' }
    let(:params) do
      {
        categories: [
          { id: SecureRandom.uuid, name: category.name },
          { id: new_category_id, name: new_category_name }
        ]
      }
    end

    let(:wordlist_entry) { create(:wordlist_entry) }

    before :each do
      create(:wordlist_entry).categories << category
      post "/wordlist_entries/#{wordlist_entry.id}/categories", params: params.to_json, headers: headers
    end

    it 'returns 201' do
      expect(response).to have_http_status(201)
    end

    it 'only new categories are added and existing one is not duplicated' do
      body = JSON.parse(response.body).deep_symbolize_keys
      expect(wordlist_entry.categories.count).to eq(2)
      expect(body[:data][:attributes][:categories]).to eq(
        [
          { id: category.id, name: category.name },
          { id: new_category_id, name: new_category_name }
        ]
      )
    end
  end
end
