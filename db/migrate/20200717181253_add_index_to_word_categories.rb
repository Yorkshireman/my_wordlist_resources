class AddIndexToWordCategories < ActiveRecord::Migration[6.0]
  def change
    add_index :word_categories, [:category_id, :wordlist_entry_id], unique: true
  end
end
