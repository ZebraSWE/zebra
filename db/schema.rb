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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121117165324) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "owners", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "company"
    t.string   "password"
    t.string   "key",        :limit => 40
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "owners", ["key"], :name => "index_owners_on_key"

  create_table "stripe_accounts", :force => true do |t|
    t.string  "auth_token"
    t.string  "access_token"
    t.string  "refresh_token"
    t.string  "state"
    t.integer "owner_id",        :null => false
    t.string  "publishable_key"
  end

  add_index "stripe_accounts", ["owner_id"], :name => "index_stripe_accounts_on_owner_id", :unique => true

  add_foreign_key "stripe_accounts", "owners", :name => "stripe_accounts_owner_id_fk"

end
