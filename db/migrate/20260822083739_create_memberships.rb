class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :desk, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "writer"

      t.timestamps
    end
    add_index :memberships, [ :desk_id, :user_id ], unique: true
  end
end
