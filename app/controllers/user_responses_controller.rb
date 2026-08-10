class UserResponsesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz

def create
    @quiz = Quiz.find(params[:quiz_id])
    @question = @quiz.questions.find(params[:question_id])

    # 1. Проверяем ответ с помощью Gemini::ResponseEvaluator
    evaluation = Gemini::ResponseEvaluator.new(
      question_prompt: @question.prompt,
      user_answer: params[:user_answer],
      correct_answer: @question.correct_answer
    ).call

    # 2. Сохраняем ответ пользователя
    @quiz.user_answers.create!(
      question: @question,
      answer_text: params[:user_answer],
      is_correct: evaluation["is_correct"],
      feedback: evaluation["feedback"]
    )

    # 3. Проверяем, ответил ли пользователь на ВСЕ вопросы
    if @quiz.user_answers.count == @quiz.questions.count
      # Если это был последний вопрос — подводим итоги!
      @quiz.complete_quiz!
      redirect_to quiz_path(@quiz), notice: "Тест завершён! Ознакомьтесь с результатами."
    else
      # Если есть еще вопросы — переходим к следующему
      redirect_to new_quiz_user_answer_path(@quiz)
    end
  end

  private

  def set_quiz
    @quiz = current_user.quizzes.find(params[:quiz_id])
  end
end
