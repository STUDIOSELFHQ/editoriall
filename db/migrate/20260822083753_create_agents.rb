class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.references :desk, null: false, foreign_key: true
      t.string :name, null: false
      t.string :role_title, null: false
      t.text :brief, null: false
      t.string :llm_model, null: false, default: "grok-4.6"
      t.string :color, null: false, default: "#2c4a6e"

      t.timestamps
    end
  end
end
