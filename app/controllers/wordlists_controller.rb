require_relative '../helpers/token_helper'

class WordlistsController < ApplicationController
  include TokenHelper
  def create
    token = request.headers['Authorization'].split(' ').last
    user_id = decode_token(token)[0]['user_id']
    wordlist = Wordlist.new(user_id: user_id)
    return unless wordlist.save

    response.status = 201
    render json: {
      data: {
        token: generate_token(user_id, wordlist.id),
        type: 'wordlist',
        attributes: {}
      }
    }
  end

  def show
    ids = request.headers['Authorization'].split(' ').last.then do |token|
      parse_ids_from_token(token)
    end

    wordlist_id = find_wordlist_id(ids)

    generate_token(ids[:user_id], wordlist_id).then do |token|
      render json: {
        data: {
          token: token,
          type: 'wordlist',
          attributes: {}
        }
      }
    end
  end

  private

  def find_wordlist_id(ids)
    ids[:wordlist_id] ? Wordlist.find(ids[:wordlist_id]).id : Wordlist.find_by!(user_id: ids[:user_id]).id
  end

  def parse_ids_from_token(token)
    decoded_token = decode_token(token)[0]
    user_id = decoded_token['user_id']
    wordlist_id = decoded_token['wordlist_id']
    unless user_id || wordlist_id
      return render_error_response(400, 'Invalid token')
    end

    { user_id: user_id, wordlist_id: wordlist_id }
  end

  def render_error_response(status, message)
    response.status = status
    render json: {
      errors: [
        { title: message }
      ]
    }
  end
end
