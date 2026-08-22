class CreateSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :seats do |t|
      t.references :piece, null: false, foreign_key: true
      t.references :seatable, polymorphic: true, null: false
      t.string :role, null: false, default: "editor"

      t.timestamps
    end
    add_index :seats, [ :piece_id, :seatable_type, :seatable_id ], unique: true, name: "index_seats_on_piece_and_seatable"
  end
end
