class User < ApplicationRecord
    has_secure_password

    #associação
    has_many :owned_teams, class_name: 'Team', foreign_key: 'owner_id', dependent: :destroy
    has_many :team_memberships, dependent: :destroy
    has_many :teams, through: :team_memberships
    has_many :assigned_tasks, class_name: 'Task', foreign_key: 'assignee_id'
    has_many :comments, dependent: :destroy

    #validação
    validates :name, presence: true, length: { minimum: 2, maximum: 50 }
    validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP}
    validates :role, inclusion: { in: %w[admin member viewer] }

    #escopo
    scope :admins, -> { where(role: 'admin') }
    scope :active, -> { where(active: true) }

    #método
    def admin?
        role == 'admin'
    end

    def member?
        role == 'member'
    end

    def viewer?
        role == 'viewer'
    end
end
