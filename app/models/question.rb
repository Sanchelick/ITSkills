class Question < ApplicationRecord
  belongs_to :quiz
  has_many :user_responses, dependent: :destroy

  enum :question_type, { mcq: 0, code_submission: 1 }
end
