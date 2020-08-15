require_relative '../helpers/token_helper'

class WordlistsController < ApplicationController
  include TokenHelper

  def create
    wordlist = Wordlist.new(user_id: @user_id)
    return unless wordlist.save

    response.status = 201
    render json: {
      data: {
        attributes: {
          created_at: wordlist.created_at
        },
        id: wordlist.id,
        token: generate_token(@user_id),
        type: 'wordlist'
      }
    }
  end

  def show
    wordlist = Wordlist.find_by!(user_id: @user_id)

    render json: {
      data: {
        attributes: {
          created_at: wordlist.created_at
        },
        id: wordlist.id,
        token: generate_token(@user_id),
        type: 'wordlist'
      }
    }
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
