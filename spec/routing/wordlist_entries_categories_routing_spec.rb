require 'rails_helper'

RSpec.describe WordlistEntriesCategoriesController, type: :routing do
  describe 'routing' do
    it 'routes to #categories' do
      expect(post: '/wordlist_entries/1/relationships/categories').to route_to(
        'wordlist_entries_categories#create', id: '1'
      )
    end
  end
end
