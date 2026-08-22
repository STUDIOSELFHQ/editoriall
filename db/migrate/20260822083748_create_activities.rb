class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.references :desk, null: false, foreign_key: true
      t.references :piece, foreign_key: true
      t.references :actor, polymorphic: true, null: false
      t.string :verb, null: false
      t.json :payload, default: {}

      t.timestamps
    end
    add_index :activities, [ :desk_id, :created_at ]
    add_index :activities, [ :piece_id, :created_at ]
  end
end
