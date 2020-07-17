class CategoriesAndWordlistEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, null: false, unique: true

      t.timestamps
    end

    create_table :wordlist_entries, id: :uuid do |t|
      t.belongs_to :word, type: :uuid
      t.belongs_to :wordlist, type: :uuid

      t.string :description

      t.timestamps
    end

    create_table :cars, id: :uuid do |t|
      t.belongs_to :category, type: :uuid
      t.belongs_to :wordlist_entry, type: :uuid

      t.timestamps
    end
  end
end
