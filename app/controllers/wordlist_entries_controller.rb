require_relative '../helpers/token_helper'

class WordlistEntriesController < ApplicationController
  include TokenHelper

  def index
    token = request.headers['Authorization'].split(' ').last
    decoded_token = decode_token(token)[0]
    wordlist_id = decoded_token['wordlist_id']

    unless wordlist_id
      return render_error_response(400, 'Invalid token - missing wordlist id')
    end

    wordlist = Wordlist.find(wordlist_id)

    wordlist_entries = wordlist.wordlist_entries.map do |wordlist_entry|
      {
        attributes: {
          word: {
            id: wordlist_entry.word.id,
            name: wordlist_entry.word.name
          },
          description: wordlist_entry.description
        }
      }
    end

    token = generate_token(wordlist.user_id, wordlist.id)
    render json: {
      data: {
        token: token,
        wordlist_entries: wordlist_entries
      }
    }

    rescue ActiveRecord::RecordNotFound => e
      render_error_response(404, e)
    rescue JWT::DecodeError => e
      render_error_response(400, e)
  end

  def create
    # token = request.headers['Authorization'].split(' ').last
    # decoded_token = decode_token(token)[0]
    # wordlist_id = decoded_token['wordlist_id'] # maybe use tap or then here
    wordlist_id = '7663812f-3358-43d6-a58a-f1859b60763f'

    unless wordlist_id
      return render_error_response(400, 'Invalid token - missing wordlist id')
    end

    wordlist = Wordlist.find(wordlist_id)
    # for now assume word does not exist yet
    word = Word.create(name: params['wordlist_entry']['word'])
    wordlist_entry = WordlistEntry.create(word_id: word.id, wordlist_id: wordlist_id, description: params['wordlist_entry']['description'])

    token = generate_token(wordlist.user_id, wordlist.id)
    render json: {
      data: {
        token: token,
        type: 'wordlist_entry',
        attributes: {
          id: wordlist_entry.id,
          word: {
            id: word.id,
            name: word.name
          },
          description: wordlist_entry.description
        }
      }
    }

    rescue ActiveRecord::RecordNotFound => e
      render_error_response(404, e)
    rescue JWT::DecodeError => e
      render_error_response(400, e)
  end

  private

  def render_error_response(status, message)
    response.status = status
    render json: {
      errors: [
        { title: message }
      ]
    }
  end
end
