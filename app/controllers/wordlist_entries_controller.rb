require_relative '../helpers/token_helper'

class WordlistEntriesController < ApplicationController
  include TokenHelper

  def create
    word = find_or_create_word(wordlist_entry_params)

    get_wordlist_id_from_headers.then do |wordlist_id|
      wordlist_entry = create_wordlist_entry(wordlist_id, word)
      token = Wordlist.find(wordlist_id).then { |wl| generate_token(wl.user_id, wl.id) }

      render json: {
        data: {
          token: token,
          type: 'wordlist-entry',
          id: wordlist_entry.id,
          attributes: parse_wordlist_entry(wordlist_entry, word)
        }
      },
      status: :created
    end
  end

  def index
    wordlist_id = get_wordlist_id_from_headers
    unless wordlist_id
      return render_error_response(400, 'Invalid token - missing wordlist id')
    end

    wordlist = Wordlist.find(wordlist_id)
    wordlist_entries = wordlist.wordlist_entries.reverse

    generate_token(wordlist.user_id, wordlist.id).then do |token|
      render json: {
        data: {
          token: token,
          wordlist_entries: parse_wordlist_entries(wordlist_entries)
        }
      }
    end
  end

  private


  def create_wordlist_entry(wordlist_id, word)
    WordlistEntry.create(wordlist_id: wordlist_id, word_id: word.id, description: wordlist_entry_params[:description])
  end

  def find_or_create_word(wordlist_entry_params)
    if wordlist_entry_params[:word][:id]
      word = Word.find(wordlist_entry_params[:word][:id])
    else
      word = Word.find_by(wordlist_entry_params[:word])
    end

    if word.nil?
      word = Word.create(wordlist_entry_params[:word])
    end

    word
  end

  def get_wordlist_id_from_headers
    request.headers['Authorization'].split(' ').last.then do |token|
      decode_token(token)[0]['wordlist_id']
    end
  end

  def parse_wordlist_entries(wordlist_entries)
    wordlist_entries.map do |wordlist_entry|
      {
        attributes: parse_wordlist_entry(wordlist_entry)
      }
    end
  end

  def parse_wordlist_entry(wordlist_entry, word = nil)
    wordlist_entry_word = word || wordlist_entry.word
    {
      word: {
        id: wordlist_entry_word.id,
        name: wordlist_entry_word.name,
        wordlist_ids: wordlist_entry_word.wordlist_ids
      },
      description: wordlist_entry.description
    }
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
    params.require(:wordlist_entry).permit(:description, word: [:id, :name])
  end
end
