class CreatePieces < ActiveRecord::Migration[8.1]
  def change
    create_table :pieces do |t|
      t.references :desk, null: false, foreign_key: true
      t.references :chair, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :dek
      t.text :body, null: false, default: ""
      t.string :status, null: false, default: "draft"
      t.integer :word_count, null: false, default: 0
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end
    add_index :pieces, [ :desk_id, :updated_at ]
  end
end
