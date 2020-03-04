require 'byebug'
require_relative '../helpers/token_helper'

class WordlistEntriesController < ApplicationController
  include TokenHelper

  def create
    puts '-----------------'
    puts params
    puts '-----------------'
    token = request.headers['Authorization'].split(' ').last
    decoded_token = decode_token(token)[0]
    wordlist_id = decoded_token['wordlist_id'] # maybe use tap or then here
  end

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
