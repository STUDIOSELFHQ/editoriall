class CreateRevisions < ActiveRecord::Migration[8.1]
  def change
    create_table :revisions do |t|
      t.references :piece, null: false, foreign_key: true
      t.references :actor, polymorphic: true, null: false
      t.text :body, null: false
      t.string :note
      t.integer :word_count, null: false, default: 0

      t.timestamps
    end
  end
end
