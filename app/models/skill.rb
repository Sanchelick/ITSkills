class Skill < ApplicationRecord
  has_many :user_skills
  has_many :quizzes

  validates :name, :slug, presence: true, uniqueness: true
end
