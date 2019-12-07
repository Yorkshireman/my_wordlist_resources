class CreateWordlistEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :wordlist_entries, id: :uuid do |t|
      t.belongs_to :word, type: :uuid, index: true
      t.belongs_to :wordlist, type: :uuid, index: true

      t.string :description

      t.timestamps
    end
  end
end
