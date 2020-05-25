require 'rails_helper'
require_relative '../../app/helpers/token_helper.rb'

RSpec.describe WordlistEntriesController do
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
      Wordlist.create(user_id: user_id_1).then do |wordlist|
        @wordlist = wordlist
        %w[foo fizz buzz].each do |word_name|
          Word.create(name: word_name).tap do |word|
            WordlistEntry.create(wordlist_id: wordlist.id, word_id: word.id, description: 'foo bar')
          end
        end

        token = generate_token(user_id_1)
        request.headers['Authorization'] = "Bearer #{token}"
        request.headers['CONTENT_TYPE'] = 'application/vnd.api+json'
      end

      get :index, params: {
        wordlist_id: @wordlist.id, format: :json
      }
    end

    it 'orders WordlistEntries by created_at attribute by newest first' do
      words_from_response = JSON.parse(response.body).deep_symbolize_keys[:data][:wordlist_entries].map do |entry|
        entry[:attributes][:word]
      end

      expect(words_from_response.first[:name]).to eq('buzz')
      expect(words_from_response.last[:name]).to eq('foo')
    end

    it 'includes wordlist_id' do
      actual_wordlist_id = JSON.parse(response.body)
                               .deep_symbolize_keys[:data][:wordlist_entries][0][:attributes][:wordlist_id]
      expected_wordlist_id = @wordlist.id
      expect(actual_wordlist_id).to eq(expected_wordlist_id)
    end

    context 'when wordlist_id does not belong to user_id in token' do
      before :each do
        Wordlist.create(user_id: user_id_2)
        token = generate_token(user_id_2)
        request.headers['Authorization'] = "Bearer #{token}"
        get :index, params: {
          wordlist_id: @wordlist.id, format: :json
        }
      end

      it 'responds with 400 http status' do
        expect(response).to have_http_status(400)
      end

      it 'error message is appropriate' do
        expected_message = 'wordlist does not belong to user'
        actual_message = JSON.parse(response.body).deep_symbolize_keys[:errors][0][:title]
        expect(actual_message).to eq(expected_message)
      end
    end
  end

  describe '#create' do
    context 'when request is valid' do
      context 'when Word does not already exist' do
        before :each do
          @wordlist = Wordlist.create(user_id: user_id_1)
          request.headers['Authorization'] = "Bearer #{generate_token(user_id_1)}"
          request.headers['CONTENT_TYPE'] = 'application/vnd.api+json'

          post :create, params: {
            wordlist_entry: {
              description: 'something to put things on',
              word: {
                name: 'table'
              }
            },
            wordlist_id: @wordlist.id,
            format: :json
          }

          @token = JWT.encode(
            { user_id: user_id_1 },
            ENV['JWT_SECRET_KEY'],
            'HS256'
          )

          @wordlist_entry_created_at = @wordlist.wordlist_entries.last.created_at
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
              token: @token,
              type: 'wordlist-entry',
              attributes: {
                created_at: JSON.parse(@wordlist_entry_created_at.to_json),
                description: 'something to put things on',
                word: {
                  id: Word.first.id,
                  name: 'table',
                  wordlist_ids: [@wordlist.id]
                },
                wordlist_id: @wordlist.id
              }
            }
          }

          actual_body = JSON.parse(response.body).deep_symbolize_keys
          expect(actual_body).to eq(expected_body)
        end
      end

      context 'when Word already exists' do
        before :each do
          @wordlist1 = Wordlist.create(user_id: user_id_1)
          generate_token(user_id_1).then { |t| request.headers['Authorization'] = "Bearer #{t}" }
          @wordlist2 = Wordlist.create(user_id: user_id_2).tap do |wordlist|
            @word = Word.create(name: 'table')
            WordlistEntry.create(
              wordlist_id: wordlist.id,
              word_id: @word.id,
              description: 'A flat platform with four legs, used to place objects on.'
            )
          end

          request.headers['CONTENT_TYPE'] = 'application/vnd.api+json'

          post :create, params: {
            wordlist_entry: {
              description: 'something to put things on',
              word: {
                name: 'table'
              }
            },
            wordlist_id: @wordlist1.id,
            format: :json
          }

          @token = JWT.encode(
            { user_id: user_id_1 },
            ENV['JWT_SECRET_KEY'],
            'HS256'
          )

          @wordlist_entry_created_at = @wordlist1.wordlist_entries.last.created_at
        end

        after :each do
          @wordlist1.words.destroy_all
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

        it 'token is correct' do
          actual_body = JSON.parse(response.body).deep_symbolize_keys
          expect(actual_body[:data][:token]).to eq(@token)
        end

        it 'has correct body' do
          expected_body = {
            data: {
              id: WordlistEntry.second.id,
              token: @token,
              type: 'wordlist-entry',
              attributes: {
                created_at: JSON.parse(@wordlist_entry_created_at.to_json),
                description: 'something to put things on',
                word: {
                  id: @word.id,
                  name: 'table',
                  wordlist_ids: [@wordlist2.id, @wordlist1.id]
                },
                wordlist_id: @wordlist1.id
              }
            }
          }

          actual_body = JSON.parse(response.body).deep_symbolize_keys

          # to produce shorter diffs for easier debugging in Travis CI
          expected_body[:data].delete(:token)
          actual_body[:data].delete(:token)

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
              wordlist_id: @wordlist1.id,
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
              wordlist_id: @wordlist1.id,
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
          request.headers['Authorization'] = "Bearer #{generate_token(user_id_1)}"
          wordlist = Wordlist.create(user_id: user_id_1)
          post :create, params: {
            wordlist_entry: {
              word: {}
            },
            wordlist_id: wordlist.id,
            format: :json
          }
        end

        it 'responds with 400 http status' do
          expect(response).to have_http_status(400)
        end

        it 'error message is appropriate' do
          expected_message = 'nil wordlist_entry params'
          actual_message = JSON.parse(response.body).deep_symbolize_keys[:errors][0][:title]
          expect(actual_message).to eq(expected_message)
        end

        it 'does not create a Word' do
          expect(Word.count).to eq(0)
        end

        it 'does not create a WordlistEntry' do
          expect(WordlistEntry.count).to eq(0)
        end
      end

      context 'when wordlist_id does not belong to user_id in token' do
        before :each do
          wordlist1 = Wordlist.create(user_id: user_id_1)
          Wordlist.create(user_id: user_id_2)

          token = generate_token(user_id_2)
          request.headers['Authorization'] = "Bearer #{token}"
          post :create, params: {
            wordlist_entry: {
              description: 'something to put things on',
              word: {
                name: 'table'
              }
            },
            wordlist_id: wordlist1.id,
            format: :json
          }
        end

        it 'responds with 400 http status' do
          expect(response).to have_http_status(400)
        end

        it 'error message is appropriate' do
          expected_message = 'wordlist does not belong to user'
          actual_message = JSON.parse(response.body).deep_symbolize_keys[:errors][0][:title]
          expect(actual_message).to eq(expected_message)
        end
      end
    end
  end
end
