class AddIndexToCars < ActiveRecord::Migration[6.0]
  def change
    add_index :cars, [:category_id, :wordlist_entry_id], unique: true
  end
end
