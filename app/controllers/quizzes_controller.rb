class QuizzesController < ApplicationController
  before_action :authenticate_user!

  # Выбор технологии и уровня
  def new
    @skills = Skill.all
  end

  # Создание теста и запрос к Gemini API
  def create
    skill = Skill.find_by(id: params[:skill_id])

    unless skill
      redirect_to new_quiz_path, alert: "Выбранная технология не найдена."
      return
    end

    target_level = params[:target_level]

    quiz = current_user.quizzes.create!(
      skill: skill,
      target_level: target_level,
      status: :in_progress
    )

    Rails.logger.info("[QuizzesController] Запуск генерации теста для Quiz ID: #{quiz.id}")

    ai_data = Gemini::QuizGenerator.new(
      skill_name: skill.name,
      target_level: target_level
    ).call

    if ai_data && ai_data["questions"].present?
      ai_data["questions"].each do |q_data|
        quiz.questions.create!(
          question_type: q_data["type"],
          prompt: q_data["prompt"],
          options: q_data["options"] || [],
          correct_answer: q_data["correct_answer"],
          code_starter: q_data["code_starter"]
        )
      end

      redirect_to quiz_path(quiz), notice: "Тест успешно сгенерирован!"
    else
      quiz.destroy # Удаляем пустой тест, если ИИ не вернул вопросы
      Rails.logger.warn("[QuizzesController] Генерация не удалась, Quiz ID: #{quiz.id} был удален.")
      redirect_to new_quiz_path, alert: "Не удалось сгенерировать тест. Проверьте лог приложения (log/development.log)."
    end
  end

  # Прохождение теста
  def show
    @quiz = current_user.quizzes.find(params[:id])
    @questions = @quiz.questions
  end
end
