require 'rails_helper'
require_relative '../../app/helpers/token_helper.rb'

RSpec.describe WordlistEntriesController do
  include ActiveSupport::Testing::TimeHelpers
  include TokenHelper
  let(:user_id_1) { SecureRandom.uuid }
  let(:user_id_2) { SecureRandom.uuid }

  before :each do
    Wordlist.destroy_all
    WordlistEntry.destroy_all
    Word.destroy_all
  end

  describe '#index' do
    before :each do
      words = []
      Wordlist.create(user_id: user_id_1).tap do |wordlist|
        ['foo', 'fizz', 'buzz'].each { |word| Word.create(name: word).then { |w| words << w } }
        words.each { |word| WordlistEntry.create(wordlist_id: wordlist.id, word_id: word.id, description: 'foo bar') }
        token = generate_token(user_id_1, wordlist.id)
        request.headers['Authorization'] = "Bearer #{token}"
        request.headers['CONTENT_TYPE'] = 'application/vnd.api+json'
      end
      get :index, format: :json
    end

    it 'orders WordlistEntries by created_at attribute by newest first' do
      words_from_response = JSON.parse(response.body).deep_symbolize_keys[:data][:wordlist_entries].map { |entry| entry[:attributes][:word] }
      expect(words_from_response.first[:name]).to eq('buzz')
      expect(words_from_response.last[:name]).to eq('foo')
    end
  end

  describe '#create' do
    context 'when request is valid' do
      context 'when Word does not already exist' do
        before :each do
          @wordlist = Wordlist.create(user_id: user_id_1).tap do |x|
            token = generate_token(user_id_1, x.id)
            request.headers['Authorization'] = "Bearer #{token}"
            request.headers['CONTENT_TYPE'] = 'application/vnd.api+json'
          end

          freeze_time do
            time_now = Time.now
            post :create, params: {
              wordlist_entry: {
                description: 'something to put things on',
                word: {
                  name: 'table'
                }
              },
              format: :json
            }

            wordlist_id = Wordlist.first.id
            @time_frozen_token = JWT.encode(
              {
                exp: (time_now + 1800).to_i,
                user_id: user_id_1,
                wordlist_id: wordlist_id
              },
              ENV['JWT_SECRET_KEY'],
              'HS256'
            )
          end
        end

        it 'responds with 201 http status' do
          expect(response).to have_http_status(201)
        end

        it 'creates a Word' do
          expect(Word.count).to eq(1)
        end

        it 'creates a WordlistEntry' do
          expect(WordlistEntry.count).to eq(1)
        end

        it 'has correct body' do
          expected_body = {
            data: {
              id: WordlistEntry.first.id,
              token: @time_frozen_token,
              type: 'wordlist-entry',
              attributes: {
                description: 'something to put things on',
                word: {
                  id: Word.first.id,
                  name: 'table',
                  wordlist_ids: [@wordlist.id]
                }
              }
            }
          }

          actual_body = JSON.parse(response.body).deep_symbolize_keys
          expect(actual_body).to eq(expected_body)
        end
      end

      context 'when Word already exists' do
        before :each do
          @wordlist_1 = Wordlist.create(user_id: user_id_1).tap do |x|
            generate_token(user_id_1, x.id).then { |t| request.headers['Authorization'] = "Bearer #{t}" }
          end

          @wordlist_2 = Wordlist.create(user_id: user_id_2).tap do |wordlist|
            @word = Word.create(name: 'table')
            WordlistEntry.create(wordlist_id: wordlist.id, word_id: @word.id, description: 'A flat platform with four legs, used to place objects on.')
          end

          request.headers['CONTENT_TYPE'] = 'application/vnd.api+json'

          freeze_time do
            time_now = Time.now
            post :create, params: {
              wordlist_entry: {
                description: 'something to put things on',
                word: {
                  name: 'table'
                }
              },
              format: :json
            }

            @time_frozen_token = JWT.encode(
              {
                exp: (time_now + 1800).to_i,
                user_id: user_id_1,
                wordlist_id: @wordlist_1.id
              },
              ENV['JWT_SECRET_KEY'],
              'HS256'
            )
          end
        end

        after :each do
          @wordlist_1.words.destroy_all
        end

        it 'responds with 201 http status' do
          expect(response).to have_http_status(201)
        end

        it 'does not create a Word' do
          expect(Word.count).to eq(1)
        end

        it 'creates a WordlistEntry' do
          expect(WordlistEntry.count).to eq(2)
        end

        it 'has correct body' do
          expected_body = {
            data: {
              id: WordlistEntry.first.id,
              token: @time_frozen_token,
              type: 'wordlist-entry',
              attributes: {
                description: 'something to put things on',
                word: {
                  id: @word.id,
                  name: 'table',
                  wordlist_ids: [@wordlist_1.id, @wordlist_2.id]
                }
              }
            }
          }

          actual_body = JSON.parse(response.body).deep_symbolize_keys
          expect(actual_body).to eq(expected_body)
        end

        context 'when Word name is not provided in the request' do
          before :each do
            post :create, params: {
              wordlist_entry: {
                description: 'something to put things on',
                word: {
                  id: @word.id
                }
              },
              format: :json
            }
          end

          it 'responds with 201 http status' do
            expect(response).to have_http_status(201)
          end

          it 'does not create a Word' do
            expect(Word.count).to eq(1)
          end

          it 'creates a WordlistEntry' do
            expect(WordlistEntry.count).to eq(3)
          end
        end

        context 'when description is not provided in the request' do
          before :each do
            post :create, params: {
              wordlist_entry: {
                word: {
                  id: @word.id
                }
              },
              format: :json
            }
          end

          it 'responds with 201 http status' do
            expect(response).to have_http_status(201)
          end

          it 'does not create a Word' do
            expect(Word.count).to eq(1)
          end

          it 'creates a WordlistEntry' do
            expect(WordlistEntry.count).to eq(3)
          end
        end
      end
    end

    context 'when request is invalid' do
      context 'when no Word attributes are provided in request' do
        before :each do
          post :create, params: {
            wordlist_entry: {
              word: {}
            },
            format: :json
          }
        end

        it 'responds with 400 http status' do
          expect(response).to have_http_status(400)
        end

        it 'does not create a Word' do
          expect(Word.count).to eq(0)
        end

        it 'does not create a WordlistEntry' do
          expect(WordlistEntry.count).to eq(0)
        end
      end
    end
  end
end
