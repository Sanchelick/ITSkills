class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.integer :question_type, null: false # enum: mcq (0), code_submission (1)
      t.text :prompt, null: false
      t.jsonb :options, default: [] # Варианты ответа для MCQ
      t.text :correct_answer, null: false
      t.text :code_starter # Шаблон кода, если вопрос на программирование
      t.timestamps
    end
  end
end
