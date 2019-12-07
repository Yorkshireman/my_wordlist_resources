class CreateWordlists < ActiveRecord::Migration[6.0]
  def change
    create_table :wordlists, id: :uuid do |t|
      t.uuid :user_id, null: false, unique: true

      t.timestamps
    end
  end
end
