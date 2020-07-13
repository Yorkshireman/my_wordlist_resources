class CategoriesController < ApplicationController
  def create
    wordlist_entry = WordlistEntry.find(params[:wordlist_entry_id])

    wordlist_entry_categories_params.each do |category_params|
      category = Category.create(category_params)
      wordlist_entry.categories << category
    end

    render json: {
      data: {
        type: 'wordlist-entry',
        id: wordlist_entry.id,
        attributes: {
          categories: JSON.parse(wordlist_entry.categories.to_json(only: [:id, :name]))
        }
      }
    }, status: :created
  end

  private

  def wordlist_entry_categories_params
    params.require(:categories).map do |category|
      category.permit(:id, :name)
    end
  end
end
