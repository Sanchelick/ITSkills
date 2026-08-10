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

ActiveRecord::Schema[8.1].define(version: 2026_08_10_143559) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "questions", force: :cascade do |t|
    t.text "code_starter"
    t.text "correct_answer", null: false
    t.datetime "created_at", null: false
    t.jsonb "options", default: []
    t.text "prompt", null: false
    t.integer "question_type", null: false
    t.bigint "quiz_id", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "score", default: 0
    t.bigint "skill_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "target_level", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["skill_id"], name: "index_quizzes_on_skill_id"
    t.index ["user_id"], name: "index_quizzes_on_user_id"
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_skills_on_slug", unique: true
  end

  create_table "user_responses", force: :cascade do |t|
    t.boolean "correct", default: false
    t.datetime "created_at", null: false
    t.text "feedback"
    t.bigint "question_id", null: false
    t.bigint "quiz_id", null: false
    t.datetime "updated_at", null: false
    t.text "user_answer"
    t.index ["question_id"], name: "index_user_responses_on_question_id"
    t.index ["quiz_id"], name: "index_user_responses_on_quiz_id"
  end

  create_table "user_skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "level", default: 0, null: false
    t.integer "score", default: 0, null: false
    t.bigint "skill_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["skill_id"], name: "index_user_skills_on_skill_id"
    t.index ["user_id", "skill_id"], name: "index_user_skills_on_user_id_and_skill_id", unique: true
    t.index ["user_id"], name: "index_user_skills_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "questions", "quizzes"
  add_foreign_key "quizzes", "skills"
  add_foreign_key "quizzes", "users"
  add_foreign_key "user_responses", "questions"
  add_foreign_key "user_responses", "quizzes"
  add_foreign_key "user_skills", "skills"
  add_foreign_key "user_skills", "users"
end
