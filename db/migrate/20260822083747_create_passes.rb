class CreatePasses < ActiveRecord::Migration[8.1]
  def change
    create_table :passes do |t|
      t.references :piece, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.references :requested_by, null: false, foreign_key: { to_table: :users }
      t.text :brief
      t.text :summary
      t.text :proposed_body
      t.json :notes, default: []
      t.string :status, null: false, default: "queued"
      t.string :error_message

      t.timestamps
    end
    add_index :passes, [ :piece_id, :status ]
  end
end
