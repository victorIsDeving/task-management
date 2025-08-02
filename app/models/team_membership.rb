class TeamMembership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  #validação
  validates :role, inclusion: { in: %w[ admin member viewer ] }
  validates :user_id, uniqueness: { scope: :team_id }

  #escopo
  scope :admins, -> { where(role: 'admin') }
  scope :members, -> { where(role: 'member') }
end
