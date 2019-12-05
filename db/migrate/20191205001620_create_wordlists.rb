class CreateWordlists < ActiveRecord::Migration[6.0]
  def change
    create_table :wordlists, id: :uuid do |t|
      t.string :user_id, null: false

      t.timestamps
    end
  end
end
