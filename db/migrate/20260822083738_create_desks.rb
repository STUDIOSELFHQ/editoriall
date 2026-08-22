class CreateDesks < ActiveRecord::Migration[8.1]
  def change
    create_table :desks do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :join_code, null: false
      t.text :description
      t.references :owner, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :desks, :slug, unique: true
    add_index :desks, :join_code, unique: true
  end
end
