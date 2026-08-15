class Quiz < ApplicationRecord
  belongs_to :user
  belongs_to :skill

  has_many :questions, dependent: :destroy
  has_many :user_responses, dependent: :destroy

  enum :target_level, { junior: 0, middle: 1, senior: 2, lead: 3 }
  enum :status, { pending: 0, in_progress: 1, completed: 2 }

  # Порог успешного прохождения теста (70%). Можно менять под свои нужды!
  PASSING_SCORE_PERCENTAGE = 70

  # 1. Количество правильных ответов пользователя в этом тесте
  def correct_answers_count
    user_answers.where(is_correct: true).count
  end

  # 2. Общее количество вопросов в тесте
  def total_questions_count
    questions.count
  end

  # 3. Расчёт процента правильных ответов (от 0 до 100)
  def calculate_score_percentage
    return 0 if total_questions_count.zero?

    ((correct_answers_count.to_f / total_questions_count) * 100).round
  end

  # 4. Метод фиксации итогов теста
  def complete_quiz!
    final_score = calculate_score_percentage
    is_passed = final_score >= PASSING_SCORE_PERCENTAGE

    update!(
      score: final_score,
      passed: is_passed,
      status: :completed # Меняем статус теста на "завершён"
    )
  end
end
