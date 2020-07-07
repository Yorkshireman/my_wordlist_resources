class AddCategoryToWordlistEntries < ActiveRecord::Migration[6.0]
  def change
    add_reference :wordlist_entries, :category, type: :uuid, foreign_key: true
  end
end
