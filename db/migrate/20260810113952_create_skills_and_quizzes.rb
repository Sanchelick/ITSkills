class CreateSkillsAndQuizzes < ActiveRecord::Migration[8.1]
  def change
    # Технологии (например, Ruby, Docker)
    create_table :skills do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.text :description
      t.timestamps
    end

    # Ачивки и уровень пользователя по навыку
    create_table :user_skills do |t|
      t.references :user, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.integer :level, default: 0, null: false # enum: junior (0), middle (1), senior (2), lead (3)
      t.integer :score, default: 0, null: false
      t.timestamps
    end
    add_index :user_skills, [ :user_id, :skill_id ], unique: true

    # Сессия теста
    create_table :quizzes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.integer :target_level, null: false
      t.integer :status, default: 0, null: false # enum: pending (0), in_progress (1), completed (2)
      t.integer :score, default: 0
      t.timestamps
    end

    # Вопросы к тесту
    create_table :questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.integer :question_type, null: false # enum: mcq (0), code_submission (1)
      t.text :prompt, null: false
      t.jsonb :options, default: [] # Варианты ответа для MCQ
      t.text :correct_answer, null: false
      t.text :code_starter # Шаблон кода, если вопрос на программирование
      t.timestamps
    end

    # Ответы пользователя
    create_table :user_responses do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :user_answer
      t.boolean :correct, default: false
      t.timestamps
    end
  end
end
