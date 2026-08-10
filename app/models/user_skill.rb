class UserSkill < ApplicationRecord
  belongs_to :user
  belongs_to :skill

  enum :level, { junior: 0, middle: 1, senior: 2, lead: 3 }
end
