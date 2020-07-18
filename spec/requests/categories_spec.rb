require 'jwt'
require 'rails_helper'
require 'securerandom'

require_relative '../../app/helpers/token_helper.rb'

RSpec.describe 'POST /wordlist_entries/:wordlist_entry_id/categories', type: :request do
  include TokenHelper
  let(:category) { Category.create(id: category_id, name: category_name) }
  let(:category_id) { SecureRandom.uuid }
  let(:category_name) { 'noun' }
  let(:headers) do
    {
      'Authorization' => "Bearer #{token}",
      'CONTENT_TYPE' => 'application/vnd.api+json'
    }
  end
  let(:token) { generate_token(user_id) }
  let(:user_id) { SecureRandom.uuid }
  let(:word) { Word.create(name: 'table') }
  let(:wordlist) { Wordlist.create(user_id: user_id) }
  let(:wordlist_entry) { WordlistEntry.create(word_id: word.id, wordlist_id: wordlist.id) }

  context 'when the WordlistEntry has no categories yet' do
    let(:params) do
      {
        categories: [
          { id: category_id, name: category_name }
        ]
      }
    end

    before :each do
      post "/wordlist_entries/#{wordlist_entry.id}/categories", params: params.to_json, headers: headers
    end

    it 'adds a Category to a WordlistEntry' do # improve test name
      expect(wordlist_entry.categories.first.id).to eq(category_id)
      expect(wordlist_entry.categories.first.name).to eq(category_name)
    end

    it 'returns 201' do
      expect(response).to have_http_status(201)
    end

    describe 'body' do
      before :each do
        @body = JSON.parse(response.body).deep_symbolize_keys
      end

      it 'has type' do
        expect(@body[:data][:type]).to eq('wordlist-entry')
      end

      it 'has id' do
        expect(@body[:data][:id]).to eq(wordlist_entry.id)
      end

      it 'has categories' do
        expect(@body[:data][:attributes][:categories]).to eq(
          [{ id: category_id, name: category_name }]
        )
      end

      it 'has a token' do
        expect(@body[:data][:token]).to eq(generate_token(user_id))
      end
    end
  end

  context 'when some categories already exist on the WordlistEntry' do
    let(:new_category_id) { SecureRandom.uuid }
    let(:new_category_name) { 'verb' }
    let(:params) do
      {
        categories: [
          { id: category_id, name: category_name },
          { id: new_category_id, name: new_category_name }
        ]
      }
    end

    before :each do
      wordlist_entry.categories << category
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
    let(:new_category_id) { SecureRandom.uuid }
    let(:new_category_name) { 'verb' }
    let(:noun2) { Word.create(name: 'chair') }
    let(:params) do
      {
        categories: [
          { id: category.id, name: category.name },
          { id: new_category_id, name: new_category_name }
        ]
      }
    end

    before :each do
      pre_existing_wordlist_entry = WordlistEntry.create(wordlist_id: wordlist.id, word_id: noun2.id)
      pre_existing_wordlist_entry.categories << category
      expect(pre_existing_wordlist_entry.categories.first.name).to eq('noun')

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

  xit 'downcases categories'
  xit 'strips whitespace'
  xit 'has a character limit'
end
