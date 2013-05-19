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

ActiveRecord::Schema.define(version: 20130518173015) do

  create_table "credentials", force: true do |t|
    t.integer  "user_id",                null: false
    t.string   "type",       limit: 32,  null: false
    t.string   "name",       limit: 128
    t.datetime "updated_at",             null: false
    t.binary   "key"
  end

  add_index "credentials", ["type", "name"], :name => "index_credentials_on_type_and_name", :unique => true
  add_index "credentials", ["type", "updated_at"], :name => "index_credentials_on_type_and_updated_at"
  add_index "credentials", ["user_id", "type"], :name => "index_credentials_on_user_id_and_type"

  create_table "player_stats", force: true do |t|
    t.integer "player_id", null: false
    t.integer "xp",        null: false
    t.integer "mana",      null: false
  end

  add_index "player_stats", ["player_id"], :name => "index_player_stats_on_player_id", :unique => true

  create_table "players", force: true do |t|
    t.string   "name",       limit: 32,             null: false
    t.integer  "user_id",                           null: false
    t.integer  "faction",               default: 0, null: false
    t.integer  "level",                 default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players", ["name"], :name => "index_players_on_name", :unique => true
  add_index "players", ["user_id"], :name => "index_players_on_user_id", :unique => true

  create_table "sites", force: true do |t|
    t.spatial  "location",       limit: {:srid=>4326, :type=>"point", :geographic=>true}, null: false
    t.integer  "site_layout_id",                                                          null: false
    t.integer  "author_id",                                                               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["author_id"], :name => "index_sites_on_author_id"
  add_index "sites", ["location"], :name => "index_sites_on_location", :spatial => true

  create_table "users", force: true do |t|
    t.string   "exuid",      limit: 32,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                 default: false
  end

  add_index "users", ["exuid"], :name => "index_users_on_exuid", :unique => true

end
