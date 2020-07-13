require 'rails_helper'

RSpec.describe CategoriesController, type: :routing do
  describe 'routing' do
    it 'routes to #categories' do
      expect(post: '/wordlist_entries/1/categories').to route_to(
        'categories#create', wordlist_entry_id: '1'
      )
    end
  end
end
