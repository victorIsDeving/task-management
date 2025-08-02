class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_task, -> (task) { where(task: task) }
  
end
