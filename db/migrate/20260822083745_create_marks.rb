class CreateMarks < ActiveRecord::Migration[8.1]
  def change
    create_table :marks do |t|
      t.references :piece, null: false, foreign_key: true
      t.references :actor, polymorphic: true, null: false
      t.text :quote
      t.text :body, null: false
      t.string :status, null: false, default: "open"

      t.timestamps
    end
    add_index :marks, [ :piece_id, :status ]
  end
end
