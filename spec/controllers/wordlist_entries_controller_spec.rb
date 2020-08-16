require 'rails_helper'
require_relative '../../app/helpers/token_helper.rb'

RSpec.describe WordlistEntriesController do
  include TokenHelper
  let(:user_id_1) { SecureRandom.uuid }
  let(:user_id_2) { SecureRandom.uuid }

  describe '#index' do
    context 'when the supplied user_id is not associated with any Wordlist' do
      before :each do
        request.headers['Authorization'] = "Bearer #{generate_token(SecureRandom.uuid)}"
        get :index
      end

      it 'responds with 404' do
        expect(response).to have_http_status(404)
      end

      it 'error message is appropriate' do
        response_body = JSON.parse(response.body).deep_symbolize_keys
        expect(response_body[:errors][0][:title]).to eq("Couldn't find Wordlist")
      end
    end
  end

  describe '#create' do
    context 'when request is valid' do
      context 'when Word does not already exist' do
        let(:wordlist) { create(:wordlist) }

        before :each do
          WordlistEntry.destroy_all

          request.headers['Authorization'] = "Bearer #{generate_token(wordlist.user_id)}"
          request.headers['CONTENT_TYPE'] = 'application/vnd.api+json'
          post :create, params: {
            wordlist_entry: {
              description: 'something to put things on',
              word: {
                name: 'table'
              }
            },
            format: :json
          }
        end

        after :each do
          Word.destroy_all
          WordlistEntry.destroy_all
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

        describe 'response body' do
          let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }

          it 'has id' do
            expected_id = wordlist.wordlist_entries.first.id
            expect(response_body[:data][:id]).to eq(expected_id)
          end

          it 'has token' do
            expect(response_body[:data][:token]).to eq(generate_token(wordlist.user_id))
          end

          it 'has type' do
            expect(response_body[:data][:type]).to eq('wordlist-entry')
          end

          it 'has categories' do
            expect(response_body[:data][:attributes][:categories]).to eq([])
          end

          it 'has created_at' do
            expect(response_body[:data][:attributes][:created_at])
              .to eq(JSON.parse(wordlist.wordlist_entries.first.created_at.to_json))
          end

          it 'has description' do
            expect(response_body[:data][:attributes][:description]).to eq('something to put things on')
          end

          it 'has word id' do
            expect(response_body[:data][:attributes][:word][:id]).to eq(Word.first.id)
          end

          it 'has word name' do
            expect(response_body[:data][:attributes][:word][:name]).to eq('table')
          end

          it "has word's wordlist_ids" do
            expect(response_body[:data][:attributes][:word][:wordlist_ids])
              .to eq([wordlist.id])
          end

          it 'has wordlist_id' do
            expect(response_body[:data][:attributes][:wordlist_id]).to eq(wordlist.id)
          end
        end
      end

      context 'when Word already exists' do
        let(:pre_existing_word) { create(:word, name: 'table') }
        let(:wordlist1) { create(:wordlist, user_id: user_id_1) }
        let(:wordlist2) { create(:wordlist, user_id: user_id_2) }

        before :each do
          # create a word and add to a user's wordlist
          create(:wordlist_entry, wordlist_id: wordlist2.id, word_id: pre_existing_word.id)
          request.headers['Authorization'] = "Bearer #{generate_token(user_id_1)}"
          request.headers['CONTENT_TYPE'] = 'application/vnd.api+json'

          # send request to add same word (by name, not id) to a different user's wordlist
          post :create, params: {
            wordlist_entry: {
              description: 'something to put things on',
              word: {
                name: pre_existing_word.name
              }
            },
            wordlist_id: wordlist1.id,
            format: :json
          }
        end

        after :each do
          wordlist1.words.destroy_all
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

        it 'adds existing word to wordlist rather than duplicating' do
          expect(wordlist1.wordlist_entries.first.word.id).to eq(pre_existing_word.id)
          expect(wordlist1.wordlist_entries.count).to eq(1)
        end

        describe 'response body' do
          let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }

          it 'has id' do
            expected_id = wordlist1.wordlist_entries.find_by(word_id: pre_existing_word.id).id
            expect(response_body[:data][:id]).to eq(expected_id)
          end

          it 'has token' do
            expect(response_body[:data][:token]).to eq(generate_token(user_id_1))
          end

          it 'has type' do
            expect(response_body[:data][:type]).to eq('wordlist-entry')
          end

          it 'has categories' do
            expect(response_body[:data][:attributes][:categories]).to eq([])
          end

          it 'has created_at' do
            expect(response_body[:data][:attributes][:created_at])
              .to eq(JSON.parse(wordlist1.wordlist_entries.last.created_at.to_json))
          end

          it 'has description' do
            expect(response_body[:data][:attributes][:description]).to eq('something to put things on')
          end

          it 'has word id' do
            expect(response_body[:data][:attributes][:word][:id]).to eq(pre_existing_word.id)
          end

          it 'has word name' do
            expect(response_body[:data][:attributes][:word][:name]).to eq(pre_existing_word.name)
          end

          it "has word's wordlist_ids" do
            expect(response_body[:data][:attributes][:word][:wordlist_ids])
              .to eq([wordlist2.id, wordlist1.id])
          end

          it 'has wordlist_id' do
            expect(response_body[:data][:attributes][:wordlist_id]).to eq(wordlist1.id)
          end
        end

        context 'when Word name is not provided in the request' do
          before :each do
            post :create, params: {
              wordlist_entry: {
                description: 'something to put things on',
                word: {
                  id: pre_existing_word.id
                }
              },
              wordlist_id: wordlist1.id,
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
                  id: pre_existing_word.id
                }
              },
              wordlist_id: wordlist1.id,
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

      context 'when id is provided' do
        let(:user_id) { SecureRandom.uuid }
        let(:uuid) { SecureRandom.uuid }
        let(:wordlist) { create(:wordlist, user_id: user_id) }

        before :each do
          request.headers['Authorization'] = "Bearer #{generate_token(wordlist.user_id)}"
          request.headers['CONTENT_TYPE'] = 'application/vnd.api+json'
        end

        context 'and is a valid uuid' do
          before :each do
            post :create, params: {
              wordlist_entry: {
                id: uuid,
                word: {
                  name: 'wordname'
                }
              },
              format: :json
            }
          end

          it 'creates WordlistEntry with provided id' do
            response_body = JSON.parse(response.body).deep_symbolize_keys
            expect(response_body[:data][:id]).to eq(uuid)
          end
        end

        context 'and is not a valid uuid' do
          before :each do
            post :create, params: {
              wordlist_entry: {
                id: '2d99808da66c9a4ac8a98f9a3a0b8295568f',
                word: {
                  name: 'wordname'
                }
              },
              format: :json
            }
          end

          it 'responds with 400 status code' do
            expect(response).to have_http_status(400)
          end

          it 'error message is appropriate' do
            response_body = JSON.parse(response.body).deep_symbolize_keys
            expect(response_body[:errors][0][:title]).to eq('Invalid WordlistEntry id')
          end

          it 'does not create a WordlistEntry' do
            expect(WordlistEntry.count).to eq(0)
          end
        end

        context 'and matches an existing id' do
          before :each do
            post :create, params: {
              wordlist_entry: {
                id: create(:wordlist_entry).id,
                word: {
                  name: 'foo'
                }
              },
              format: :json
            }
          end

          it 'responds with 422 status code' do
            expect(response).to have_http_status(422)
          end

          it 'error message is appropriate' do
            response_body = JSON.parse(response.body).deep_symbolize_keys
            expect(response_body[:errors][0][:title]).to eq('id is not unique')
          end

          it 'does not create a WordlistEntry' do
            expect(WordlistEntry.count).to eq(1)
          end
        end
      end
    end

    context 'when request is invalid' do
      context 'when Wordlist cannot be found by wordlist_id' do
        before :each do
          request.headers['Authorization'] = "Bearer #{generate_token(SecureRandom.uuid)}"
          post :create, params: {
            wordlist_entry: {
              word: {
                name: 'foo'
              }
            },
            format: :json
          }
        end

        it 'responds with 404' do
          expect(response).to have_http_status(404)
        end

        it 'error message is appropriate' do
          response_body = JSON.parse(response.body).deep_symbolize_keys
          expect(response_body[:errors][0][:title]).to eq("Couldn't find Wordlist")
        end
      end

      context 'when no Word attributes are provided in request' do
        before :each do
          wordlist = create(:wordlist)
          request.headers['Authorization'] = "Bearer #{generate_token(wordlist.user_id)}"

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
          response_body = JSON.parse(response.body).deep_symbolize_keys
          expect(response_body[:errors][0][:title]).to eq('nil wordlist_entry params')
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
