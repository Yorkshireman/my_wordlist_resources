class CategoriesAndWordlistEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, null: false, unique: true

      t.timestamps
    end

    create_table :wordlist_entries, id: :uuid do |t|
      t.belongs_to :word, type: :uuid, index: true
      t.belongs_to :wordlist, type: :uuid, index: true

      t.string :description

      t.timestamps
    end

    create_table :categories_wordlist_entries, id: false do |t|
      t.belongs_to :category, type: :uuid
      t.belongs_to :wordlist_entry, type: :uuid
    end
  end
end
