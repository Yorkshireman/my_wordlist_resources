require_relative '../helpers/token_helper'

class CategoriesController < ApplicationController
  include TokenHelper
  # rubocop:disable Metrics/AbcSize
  def create
    user_id = parse_user_id_from_headers(request.headers)
    wordlist_entry = WordlistEntry.find(params[:wordlist_entry_id])

    wordlist_entry_categories_params.each do |category_params|
      category = find_or_create_category(category_params)
      wordlist_entry.categories << category unless wordlist_entry.categories.include?(category)
    end

    render json: {
      data: {
        attributes: {
          categories: JSON.parse(wordlist_entry.categories.to_json(only: [:id, :name]))
        },
        id: wordlist_entry.id,
        token: generate_token(user_id),
        type: 'wordlist-entry'
      }
    }, status: :created
  end
  # rubocop:enable Metrics/AbcSize

  private

  def find_or_create_category(category_params)
    raise_error ArgumentError.new('No category params provided') if category_params.empty?
    return Category.find(category_params[:id]) if Category.exists?(category_params[:id])

    Category.create(category_params)
  end

  def parse_user_id_from_headers(headers)
    headers['Authorization'].split(' ').last.then do |token|
      decode_token(token)[0]['user_id']
    end
  end

  def wordlist_entry_categories_params
    params.require(:categories).map do |category|
      category.permit(:id, :name)
    end
  end
end
