class Api::V1::TeamsController < Api::V1::BaseController
    before_action :set_team, only: [:show, :update, :destroy, :add_member, :remove_member]
    before_action :authorize_team_access, only: [:show, :update, :destroy]
    before_action :authorize_team_admin, only: [:update, :destroy, :add_member, :remove_member]

    def index
        @teams = current_user.teams.includes(:owner,:members,:projects)
        render_success(teams_json(@teams))
    end

    def show
        render_success(team_json(@team, include_members: true))
    end

    def create
        @team = Team.new(team_params)
        @team.owner = current_user

        if @team.save
            @team.add_member(current_user, 'admin')
            render_success(team_json(@team), 'success create', :created)
        else
            render_error(@team)
        end
    end

    def update
        if @team.update(team_params)
            render_success(team_json(@team), 'success update')
        else
            render_error(@team)
        end
    end

    def destroy
        @team.destroy
        render_success(nil, 'success delete')
    end

    def add_member
        user = User.find_by(email: params[:email])

        if user.nil?
            return render json: 
            { error: 'not a user' }, status: :not_found
        end

        if @team.members.include?(user)
            return render json: 
            { error: 'already a member' }, status: unprocessable_entity
        end

        membership = @team.add_member(user, params[:role] || 'member')
    
        if membership.persisted?
            render_success(
                {user:user_json(user), role: membership.role},
                'member added'
            )
        else
            render_error(membership)
        end
    end

    def remove_member
        user = User.find(params[:user_id])
        membership = @team.team_memberships.find_by(user: user)

        if membership.nil?
            return render json:
            {error: 'not a member'}, status: :not_found
        end

        if user == @team.owner
            return render json:
            {error: 'user is team owner'}, status: unprocessable_entity
        end

        membership.destroy
        render_success(nil, 'member removed')
    rescue ActiveRecord::RecordNotFound
        render json:
        {error:'user not found'}, status: :not_found
    end

    private

    def set_team
        @team = Team.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json:
        {error:'Team doesn\'t exist'}, error: :not_found
    end

    def authorize_team_admin
        membership = @team.team_memberships.find_by(user: current_user)
        unless @team.owner == current_user || (membership&.role == 'admin')
            render json:
            {error:'not admin'},status: :forbidden
        end
    end

    def team_params
        params.require(:team).permit(:name,:description)
    end

    def teams_json(teams)
        teams.map {|team| team_json(team)}
    end

    def team_json(team, include_members: false)
        result = {
            id: team.id,
            name: team.name,
            description: team.description,
            owner: user_json(team.owner),
            projects_count: team.projects.count,
            created_at: team.created_at
        }

        if include_members
            result[:members] = team.members.map do |member|
                membership = team.team_memberships.find_by(user: member)
                user_json(member).merge(role: membership.role)
            end
        end

        result
    end

    def user_json(user)
        {
            id:user.id,
            name: user.name,
            email: user.email,
            role: user.role
        }
    end
end