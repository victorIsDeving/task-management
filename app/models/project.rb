class Project < ApplicationRecord
  belongs_to :team

  #associações
  has_many :tasks, dependent: :destroy

  #validações
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :status, inclusion: { in: %w[active completed archived] }

  #escopos
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :archived, -> { where(status: 'archived') }

  #métodos
  def complete!
    update!(status: 'completed')
  end

  def archive!
    update!(status: 'archived')
  end

  def completion_percentage
    return 0 if tasks.count.zero?
    (tasks.completed.count.to_f / tasks.count * 100).round(2)
  end
end
