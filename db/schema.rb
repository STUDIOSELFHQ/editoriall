# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_22_083753) do
  create_table "activities", force: :cascade do |t|
    t.integer "actor_id", null: false
    t.string "actor_type", null: false
    t.datetime "created_at", null: false
    t.integer "desk_id", null: false
    t.json "payload", default: {}
    t.integer "piece_id"
    t.datetime "updated_at", null: false
    t.string "verb", null: false
    t.index ["actor_type", "actor_id"], name: "index_activities_on_actor"
    t.index ["desk_id", "created_at"], name: "index_activities_on_desk_id_and_created_at"
    t.index ["desk_id"], name: "index_activities_on_desk_id"
    t.index ["piece_id", "created_at"], name: "index_activities_on_piece_id_and_created_at"
    t.index ["piece_id"], name: "index_activities_on_piece_id"
  end

  create_table "agents", force: :cascade do |t|
    t.text "brief", null: false
    t.string "color", default: "#2c4a6e", null: false
    t.datetime "created_at", null: false
    t.integer "desk_id", null: false
    t.string "llm_model", default: "grok-4.6", null: false
    t.string "name", null: false
    t.string "role_title", null: false
    t.datetime "updated_at", null: false
    t.index ["desk_id"], name: "index_agents_on_desk_id"
  end

  create_table "desks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "join_code", null: false
    t.string "name", null: false
    t.integer "owner_id", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["join_code"], name: "index_desks_on_join_code", unique: true
    t.index ["owner_id"], name: "index_desks_on_owner_id"
    t.index ["slug"], name: "index_desks_on_slug", unique: true
  end

  create_table "marks", force: :cascade do |t|
    t.integer "actor_id", null: false
    t.string "actor_type", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "piece_id", null: false
    t.text "quote"
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_marks_on_actor"
    t.index ["piece_id", "status"], name: "index_marks_on_piece_id_and_status"
    t.index ["piece_id"], name: "index_marks_on_piece_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "desk_id", null: false
    t.string "role", default: "writer", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["desk_id", "user_id"], name: "index_memberships_on_desk_id_and_user_id", unique: true
    t.index ["desk_id"], name: "index_memberships_on_desk_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "passes", force: :cascade do |t|
    t.integer "agent_id", null: false
    t.text "brief"
    t.datetime "created_at", null: false
    t.string "error_message"
    t.json "notes", default: []
    t.integer "piece_id", null: false
    t.text "proposed_body"
    t.integer "requested_by_id", null: false
    t.string "status", default: "queued", null: false
    t.text "summary"
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_passes_on_agent_id"
    t.index ["piece_id", "status"], name: "index_passes_on_piece_id_and_status"
    t.index ["piece_id"], name: "index_passes_on_piece_id"
    t.index ["requested_by_id"], name: "index_passes_on_requested_by_id"
  end

  create_table "pieces", force: :cascade do |t|
    t.text "body", default: "", null: false
    t.integer "chair_id", null: false
    t.datetime "created_at", null: false
    t.string "dek"
    t.integer "desk_id", null: false
    t.integer "lock_version", default: 0, null: false
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "word_count", default: 0, null: false
    t.index ["chair_id"], name: "index_pieces_on_chair_id"
    t.index ["desk_id", "updated_at"], name: "index_pieces_on_desk_id_and_updated_at"
    t.index ["desk_id"], name: "index_pieces_on_desk_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.integer "actor_id", null: false
    t.string "actor_type", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "note"
    t.integer "piece_id", null: false
    t.datetime "updated_at", null: false
    t.integer "word_count", default: 0, null: false
    t.index ["actor_type", "actor_id"], name: "index_revisions_on_actor"
    t.index ["piece_id"], name: "index_revisions_on_piece_id"
  end

  create_table "seats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "piece_id", null: false
    t.string "role", default: "editor", null: false
    t.integer "seatable_id", null: false
    t.string "seatable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["piece_id", "seatable_type", "seatable_id"], name: "index_seats_on_piece_and_seatable", unique: true
    t.index ["piece_id"], name: "index_seats_on_piece_id"
    t.index ["seatable_type", "seatable_id"], name: "index_seats_on_seatable"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "activities", "desks"
  add_foreign_key "activities", "pieces"
  add_foreign_key "agents", "desks"
  add_foreign_key "desks", "users", column: "owner_id"
  add_foreign_key "marks", "pieces"
  add_foreign_key "memberships", "desks"
  add_foreign_key "memberships", "users"
  add_foreign_key "passes", "agents"
  add_foreign_key "passes", "pieces"
  add_foreign_key "passes", "users", column: "requested_by_id"
  add_foreign_key "pieces", "desks"
  add_foreign_key "pieces", "users", column: "chair_id"
  add_foreign_key "revisions", "pieces"
  add_foreign_key "seats", "pieces"
  add_foreign_key "sessions", "users"
end
