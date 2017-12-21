# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140403230549) do

  create_table "corporations", force: true do |t|
    t.integer  "game_session_id"
    t.integer  "money"
    t.integer  "income"
    t.string   "initials"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_sessions", force: true do |t|
    t.integer  "bank"
    t.text     "companies"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "previous_state"
  end

  create_table "players", force: true do |t|
    t.string   "name"
    t.integer  "money"
    t.integer  "game_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shares", force: true do |t|
    t.integer  "player_id"
    t.integer  "corporation_id"
    t.integer  "quantity"
    t.integer  "game_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
