class AddFeedbackToUserResponses < ActiveRecord::Migration[8.1]
  def change
    add_column :user_responses, :feedback, :text
  end
end
