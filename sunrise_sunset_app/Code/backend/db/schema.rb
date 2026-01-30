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

ActiveRecord::Schema[8.1].define(version: 2024_01_01_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "sunrise_sunset_records", force: :cascade do |t|
    t.string "astronomical_twilight_begin"
    t.string "astronomical_twilight_end"
    t.string "civil_twilight_begin"
    t.string "civil_twilight_end"
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "day_length"
    t.string "golden_hour"
    t.string "golden_hour_end"
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.string "location", null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "nautical_twilight_begin"
    t.string "nautical_twilight_end"
    t.string "solar_noon"
    t.string "status"
    t.string "sunrise"
    t.string "sunset"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_sunrise_sunset_records_on_created_at"
    t.index ["date"], name: "index_sunrise_sunset_records_on_date"
    t.index ["latitude", "longitude", "date"], name: "index_sunrise_sunset_on_coords_and_date"
    t.index ["location", "date"], name: "index_sunrise_sunset_on_location_and_date", unique: true
  end
end
