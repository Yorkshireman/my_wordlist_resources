require_relative '../helpers/token_helper'

class WordlistsController < ApplicationController
  include TokenHelper
  def create
    token = request.headers['Authorization'].split(' ').last
    user_id = decode_token(token)[0]['user_id']
    wordlist = Wordlist.new(user_id: user_id)
    if wordlist.save
      token = generate_token({ exp: (Time.now + 1800).to_i, wordlist_id: wordlist.id })
      response.status = 201
      render json: {
        data: {
          token: token
        }
      }
    end
  end

  def show
    token = request.headers['Authorization'].split(' ').last
    decoded_token = decode_token(token)[0]
    unless decoded_token['user_id'] || decoded_token['wordlist_id']
      render_error_response(400, 'Invalid token')
    end

    wordlist = decoded_token['user_id'] ? Wordlist.find_by!(user_id: decoded_token['user_id']) : Wordlist.find(decoded_token['wordlist_id'])
    serialised_wordlist = JSON.parse(wordlist.to_json).symbolize_keys

    generate_token({ exp: (Time.now + 1800).to_i, wordlist_id: serialised_wordlist[:id] }).then do |token|
      render json: {
        data: {
          token: token,
          type: 'wordlist',
          id: serialised_wordlist[:id],
          attributes: {
            created_at: serialised_wordlist[:created_at],
            updated_at: serialised_wordlist[:updated_at],
            user_id: serialised_wordlist[:user_id]
          }
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
