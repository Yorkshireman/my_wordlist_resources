require 'byebug'
require_relative '../helpers/token_helper'

class WordlistEntriesController < ApplicationController
  include TokenHelper

  def create
    wordlist_id = get_wordlist_id_from_headers(request.headers)
    word = Word.find_by(wordlist_entry_params[:word]).then do |word|
      word || Word.create(wordlist_entry_params[:word])
    end

    if wordlist_entry = WordlistEntry.create(
      wordlist_id: wordlist_id,
      word_id: word.id,
      description: wordlist_entry_params[:description]
    )
      token = Wordlist.find(wordlist_id).then { |wl| generate_token(wl.user_id, wl.id) }
      render json: {
        data: {
          token: token,
          type: 'wordlist-entry',
          id: wordlist_entry.id,
          attributes: {
            description: wordlist_entry.description,
            word: {
              id: word.id,
              name: word.name,
              wordlist_ids: word.wordlist_ids
            }
          }
        }
      },
      status: :created
    end
  end

  def index
    wordlist_id = get_wordlist_id_from_headers(request.headers)
    unless wordlist_id
      return render_error_response(400, 'Invalid token - missing wordlist id')
    end

    wordlist = Wordlist.find(wordlist_id)

    wordlist_entries = wordlist.wordlist_entries.map do |wordlist_entry|
      {
        attributes: {
          word: {
            id: wordlist_entry.word.id,
            name: wordlist_entry.word.name,
            wordlist_ids: wordlist_entry.word.wordlist_ids
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

  private

  def get_wordlist_id_from_headers(request_headers)
    request_headers['Authorization'].split(' ').last.then do |token|
      decode_token(token)[0]['wordlist_id']
    end
  end

  def render_error_response(status, message)
    response.status = status
    render json: {
      errors: [
        { title: message }
      ]
    }
  end

  def wordlist_entry_params
    params.require(:wordlist_entry).permit(:description, word: [:name])
  end
end
