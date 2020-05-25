require_relative '../helpers/token_helper'

class WordlistEntriesController < ApplicationController
  include TokenHelper
  # rubocop:disable Metrics/AbcSize
  def create
    if params[:wordlist_entry].nil?
      return render_error_response(400, 'nil wordlist_entry params')
    end

    user_id = parse_user_id_from_headers(request.headers)
    wordlist = Wordlist.find(params[:wordlist_id])

    if wordlist.user_id != user_id
      return render_error_response(400, 'wordlist does not belong to user')
    end

    word = find_or_create_word
    wordlist_entry = WordlistEntry.create(wordlist_entry_params(word.id))

    render json: {
      data: {
        token: generate_token(wordlist.user_id),
        type: 'wordlist-entry',
        id: wordlist_entry.id,
        attributes: parse_wordlist_entry(wordlist_entry, word)
      }
    }, status: :created
  end

  def index
    @wordlist_id = wordlist_params[:wordlist_id]
    unless @wordlist_id
      return render_error_response(400, 'missing wordlist id')
    end

    wordlist = Wordlist.find(@wordlist_id)
    user_id = parse_user_id_from_headers(request.headers)

    if wordlist.user_id != user_id
      return render_error_response(400, 'wordlist does not belong to user')
    end

    wordlist_entries = wordlist.wordlist_entries.sort_by(&:created_at).reverse

    generate_token(wordlist.user_id).then do |token|
      render json: {
        data: {
          token: token,
          wordlist_entries: parse_wordlist_entries(wordlist_entries)
        }
      }
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def find_or_create_word
    word_id = params[:wordlist_entry][:word][:id]
    word_name = params[:wordlist_entry][:word][:name]
    word = if word_id
             Word.find(word_id)
           else
             Word.find_by(name: word_name)
           end

    word || Word.create(word_params)
  end

  def parse_user_id_from_headers(headers)
    headers['Authorization'].split(' ').last.then do |token|
      decode_token(token)[0]['user_id']
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
      created_at: wordlist_entry.created_at,
      description: wordlist_entry.description,
      wordlist_id: params[:wordlist_id]
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

  def word_params
    params.require(:wordlist_entry).permit(word: :name)[:word]
  end

  def wordlist_params
    params.permit(:wordlist_id)
  end

  def wordlist_entry_params(word_id)
    params.require(:wordlist_entry).permit(:description, word: :id).tap do |sanitised_params|
      return {
        description: sanitised_params[:description],
        word_id: word_id,
        wordlist_id: wordlist_params[:wordlist_id]
      }
    end
  end
end
