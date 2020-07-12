class WordlistEntriesCategoriesController < ApplicationController
  def create
    wordlist_entry = WordlistEntry.find(params[:wordlist_entry_id])
    wordlist_entries_category_params[:categories].each do |category_params|
      @category = Category.create(category_params)
      wordlist_entry.categories << @category
    end

    render json: {
      data: {
        type: 'wordlist-entry',
        id: wordlist_entry.id,
        attributes: {
          categories: [
            JSON.parse(@category.to_json(only: [:id, :name]))
          ]
        }
      }
    }, status: :created
  end

  private

  def wordlist_entries_category_params
    params.require(:wordlist_entries_category).permit(categories: [:id, :name])
  end
end
