module Gemini
  class QuizGeneratorService
    def self.call(user:, skill:, level:)
      # 1. Генерация текста от Gemini API
      raw_data = Gemini::QuizGenerator.generate_quiz(skill.name, level)
      
      # 2. Создание Quiz и вопросов в транзакции БД
      ActiveRecord::Base.transaction do
        quiz = Quiz.create!(
          user: user,
          skill: skill,
          title: "Тест по #{skill.name} (#{level})",
          status: :in_progress
        )

        raw_data["questions"].each do *q_data*
                                      quiz.questions.create!(
                                        content: q_data["content"],
                                        code_snippet: q_data["code_snippet"],
                                        options: q_data["options"], # JSONB или Array
                                        correct_answer: q_data["correct_answer"]
                                      )
        end

        quiz
      end
    end
  end
end
