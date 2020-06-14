require_relative '../helpers/token_helper'

class WordlistsController < ApplicationController
  include TokenHelper
  def create
    user_id = parse_token_from_headers(request.headers).then do |token|
      parse_user_id_from_token(token) || render_error_response(400, 'Invalid token')
    end

    wordlist = Wordlist.new(user_id: user_id)
    return unless wordlist.save

    response.status = 201
    render json: {
      data: {
        attributes: {
          created_at: wordlist.created_at
        },
        id: wordlist.id,
        token: generate_token(user_id),
        type: 'wordlist'
      }
    }
  end

  def show
    user_id = parse_token_from_headers(request.headers).then do |token|
      parse_user_id_from_token(token) || render_error_response(400, 'Invalid token')
    end

    wordlist = Wordlist.find_by!(user_id: user_id)

    render json: {
      data: {
        attributes: {
          created_at: wordlist.created_at
        },
        id: wordlist.id,
        token: generate_token(user_id),
        type: 'wordlist'
      }
    }
  end

  private

  def parse_token_from_headers(headers)
    headers['Authorization'].split(' ').last
  end

  def parse_user_id_from_token(token)
    decoded_token = decode_token(token)[0]
    decoded_token['user_id']
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
