class Team < ApplicationRecord
  #associação
  belongs_to :owner, class_name: 'User'
  has_many :team_memberships, dependent: :destroy
  has_many :members, through: :team_memberships, source: :user
  has_many :projects, dependent: :destroy

  #validação
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 500 }

  #escopo
  scope :active, -> { joins(:projects).distinct }

  #métodos
  def add_member(user, role = 'member')
    team_memberships.create(user: user, role: role)
  end

  def remove_member(user)
    team_memberships.find_by(user: user)&.destroy
  end
  
end
