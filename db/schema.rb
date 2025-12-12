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

ActiveRecord::Schema[8.1].define(version: 2025_12_12_022359) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blog_posts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "featured", default: false
    t.datetime "published_at"
    t.integer "reading_time"
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0
    t.boolean "viral", default: false
    t.index ["published_at"], name: "index_blog_posts_on_published_at"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
    t.index ["viral"], name: "index_blog_posts_on_viral"
  end

  create_table "books", force: :cascade do |t|
    t.string "affiliate_link"
    t.string "author", null: false
    t.string "category"
    t.string "cover_url"
    t.datetime "created_at", null: false
    t.boolean "featured", default: false
    t.string "isbn"
    t.integer "rating"
    t.date "read_date"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_books_on_category"
    t.index ["featured"], name: "index_books_on_featured"
    t.index ["rating"], name: "index_books_on_rating"
    t.index ["read_date"], name: "index_books_on_read_date"
  end

  create_table "gear_items", force: :cascade do |t|
    t.string "affiliate_link"
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.boolean "featured", default: false
    t.string "image_url"
    t.string "name", null: false
    t.integer "position", default: 0
    t.decimal "price", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_gear_items_on_category"
    t.index ["featured"], name: "index_gear_items_on_featured"
    t.index ["position"], name: "index_gear_items_on_position"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "featured", default: false
    t.string "logo_url"
    t.string "name", null: false
    t.integer "position", default: 0
    t.string "project_type", null: false
    t.string "status", default: "active"
    t.text "tech_stack"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["featured"], name: "index_projects_on_featured"
    t.index ["position"], name: "index_projects_on_position"
    t.index ["project_type"], name: "index_projects_on_project_type"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "social_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "display_in_header", default: true
    t.integer "follower_count"
    t.string "platform", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.string "username"
    t.index ["platform"], name: "index_social_links_on_platform"
  end

  create_table "sport_activities", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "event_name"
    t.string "location"
    t.boolean "personal_record", default: false
    t.string "result_url"
    t.string "sport_type", null: false
    t.string "sub_type"
    t.string "title", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["category"], name: "index_sport_activities_on_category"
    t.index ["date"], name: "index_sport_activities_on_date"
    t.index ["personal_record"], name: "index_sport_activities_on_personal_record"
    t.index ["sport_type"], name: "index_sport_activities_on_sport_type"
    t.index ["sub_type"], name: "index_sport_activities_on_sub_type"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "sessions", "users"
end
