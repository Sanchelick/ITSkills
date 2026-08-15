class UserResponse < ApplicationRecord
  # Связи с другими моделями (внешние ключи user_id, quiz_id, question_id)
  belongs_to :user
  belongs_to :quiz
  belongs_to :question

  # Валидация: пользователь не может отправить пустой ответ
  validates :user_answer, presence: true
end
