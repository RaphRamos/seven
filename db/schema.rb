# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_23_092954) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "agent_locations", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_agent_locations_on_agent_id"
    t.index ["location_id"], name: "index_agent_locations_on_location_id"
  end

  create_table "agents", force: :cascade do |t|
    t.string "name", null: false
    t.string "display_name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_zone", default: "Perth"
    t.string "language", default: "English, Portuguese"
    t.boolean "active", default: true
  end

  create_table "appointments", force: :cascade do |t|
    t.string "desc", null: false
    t.float "price", null: false
    t.integer "returns", default: 1, null: false
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_references", force: :cascade do |t|
    t.string "desc", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "location", null: false
    t.string "phone", null: false
    t.string "email", null: false
    t.boolean "premium", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference"
    t.string "videocall_details"
    t.string "ip_address"
    t.string "country"
    t.string "state"
  end

  create_table "event_services", force: :cascade do |t|
    t.string "desc"
    t.float "first_app_price"
    t.float "return_app_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_types", force: :cascade do |t|
    t.string "desc", null: false
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.bigint "event_type_id", null: false
    t.bigint "appointment_id", null: false
    t.bigint "client_id", null: false
    t.datetime "start", null: false
    t.datetime "end", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "temporary", default: true, null: false
    t.text "notes"
    t.boolean "by_admin", default: true, null: false
    t.string "admin_comment"
    t.bigint "event_service_id"
    t.bigint "location_id", default: 1
    t.string "language", default: "English"
    t.boolean "offshore"
    t.index ["agent_id"], name: "index_events_on_agent_id"
    t.index ["appointment_id"], name: "index_events_on_appointment_id"
    t.index ["client_id"], name: "index_events_on_client_id"
    t.index ["event_service_id"], name: "index_events_on_event_service_id"
    t.index ["event_type_id"], name: "index_events_on_event_type_id"
    t.index ["location_id"], name: "index_events_on_location_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address", default: ""
    t.string "city"
    t.string "postcode"
    t.string "state"
    t.string "phone"
    t.string "office_name", default: "Seven Migration"
    t.string "timezone"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.float "price", default: 0.0, null: false
    t.bigint "client_id", null: false
    t.bigint "event_id", null: false
    t.string "transaction_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_payments_on_client_id"
    t.index ["event_id"], name: "index_payments_on_event_id"
  end

  create_table "timetable_event_types", force: :cascade do |t|
    t.bigint "timetable_id"
    t.bigint "event_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type_id"], name: "index_timetable_event_types_on_event_type_id"
    t.index ["timetable_id"], name: "index_timetable_event_types_on_timetable_id"
  end

  create_table "timetables", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.string "dow", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.boolean "activated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "from_date"
    t.date "to_date"
    t.bigint "location_id"
    t.index ["agent_id"], name: "index_timetables_on_agent_id"
    t.index ["location_id"], name: "index_timetables_on_location_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "agent_locations", "agents"
  add_foreign_key "agent_locations", "locations"
  add_foreign_key "events", "agents"
  add_foreign_key "events", "appointments"
  add_foreign_key "events", "clients"
  add_foreign_key "events", "event_services"
  add_foreign_key "events", "event_types"
  add_foreign_key "payments", "clients"
  add_foreign_key "payments", "events"
  add_foreign_key "timetable_event_types", "event_types"
  add_foreign_key "timetable_event_types", "timetables"
  add_foreign_key "timetables", "agents"
end
