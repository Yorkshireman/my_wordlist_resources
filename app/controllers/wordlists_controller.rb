require_relative '../helpers/token_helper'

class WordlistsController < ApplicationController
  include TokenHelper
  def create
    token = request.headers['Authorization'].split(' ').last
    user_id = decode_token(token)[0]['user_id']
    wordlist = Wordlist.new(user_id: user_id)
    if wordlist.save
      token = generate_token(user_id, wordlist.id)
      response.status = 201
      render json: {
        data: {
          token: token,
          type: 'wordlist',
          attributes: {}
        }
      }
    end
  end

  def show
    token = request.headers['Authorization'].split(' ').last
    decoded_token = decode_token(token)[0]
    user_id = decoded_token['user_id']
    wordlist_id = decoded_token['wordlist_id']
    unless user_id || wordlist_id
      render_error_response(400, 'Invalid token')
    end

    wordlist = wordlist_id ? Wordlist.find(wordlist_id) : Wordlist.find_by!(user_id: user_id)
    # serialised_wordlist = JSON.parse(wordlist.to_json).symbolize_keys

    generate_token(user_id, wordlist.id).then do |token|
      render json: {
        data: {
          token: token,
          type: 'wordlist',
          attributes: {}
        }
      }
    end

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
