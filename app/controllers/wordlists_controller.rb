require_relative '../helpers/token_helper'

class WordlistsController < ApplicationController
  include TokenHelper

  def create
    wordlist = Wordlist.create!(user_id: @user_id)

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
end
