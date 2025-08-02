class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assignee, class_name: 'User', optional: true
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { minimum: 2, maximum: 200 }
  validates :description, lenght: { maximum: 2000 }
  validates :priority, inclusion: { in: %w[ low medium high urgent ] }
  validates :status, inclusion: { in: %w[ todo in_progress review done] }

  scope :todo, -> { where(status: 'todo') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'done') }
  scope :overdue, -> { where('due_date < ? AND status != ?', Time.current, 'done') }
  scope :by_priority, -> (priority) { where(priority: priority) }
  scope :assigned_to, -> (user) { where(assignee: user) }

  def overdue?
    due_date.present? && due_date < Time.current && status != 'done'
  end

  def compelete!
    update!(status: 'done')
  end

  def assign_to(user)
    update!(assignee: user)
  end
end
