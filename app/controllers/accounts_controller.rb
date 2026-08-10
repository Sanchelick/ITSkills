
class AccountsController < ApplicationController
  before_action :authenticate_user!

  # Страница личного кабинета с ачивками
  def show
    @user = current_user
    @user_skills = @user.user_skills.includes(:skill)
    @recent_quizzes = @user.quizzes.order(created_at: :desc).limit(5)
  end
end
