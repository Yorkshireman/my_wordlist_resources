class WordlistEntriesCategoriesController < ApplicationController
  def create
    category = Category.create(id: params[:wordlist_entries_category]['categories'][0]['id'], name: params[:wordlist_entries_category]['categories'][0]['name'])
    wordlist_entry = WordlistEntry.find(params[:wordlist_entry_id])
    wordlist_entry.categories << category
    render json: {
      data: {
        type: 'wordlist-entry',
        id: wordlist_entry.id,
        attributes: {
          categories: [
            JSON.parse(category.to_json(only: [:id, :name]))
          ]
        }
      }
    }, status: :created
  end
end
