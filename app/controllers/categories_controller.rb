require_relative '../helpers/token_helper'

class CategoriesController < ApplicationController
  include TokenHelper

  def create
    wordlist_entry = WordlistEntry.find(params[:wordlist_entry_id])
    add_categories(wordlist_entry, wordlist_entry_categories_params)

    render json: {
      data: {
        attributes: {
          categories: JSON.parse(wordlist_entry.categories.to_json(only: [:id, :name]))
        },
        id: wordlist_entry.id,
        token: generate_token(@user_id),
        type: 'wordlist-entry'
      }
    }, status: :created
  end

  private

  def add_categories(wordlist_entry, categories)
    categories.each do |category_params|
      category = find_or_create_category(category_params)
      wordlist_entry.categories << category unless wordlist_entry.categories.include?(category)
    end
  end

  def find_or_create_category(category_params)
    raise_error ArgumentError.new('No category params provided') if category_params.empty?
    return Category.find_by(name: category_params[:name]) if Category.exists?(name: category_params[:name])

    Category.create(category_params)
  end

  def wordlist_entry_categories_params
    params.require(:categories).map do |category|
      category.permit(:id, :name)
    end
  end
end
