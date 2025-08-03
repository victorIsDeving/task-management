class Api::V1::ProjectsController < Api::V1::BaseController
    before_action :set_team
    before_action :set_project, only: [:show,:update,:destroy]
    before_action :authorize_team_access
    before_action :authorize_project_access, only: [:update,:destroy]

    def index
        @projects = @team.projects.includes(:tasks)
                        .page(params[:page])
                        .per(params[:per_page] || 10)
        render_success({
            projects: projects_json(@projects),
            pagination: pagination_json(@projects)
        })
    end

    def show
        render_success(project_json(@project, include_tasks: true))
    end

    def create
        @project = @team.projects.build(project_params)

        if @project.save
            render_success(project_json(@project), 'success', :created)
        else
            render_error(@project)
        end
    end

    def update
        if @project.update(project_params)
            render_success(project_json(@project), 'success')
        else
            render_error(@project)
        end
    end

    def destroy
        @project.destroy
        render_success(nil,'success')
    end

    private

    def set_team
        @team = current_user.teams.find(params[:team_id])
    rescue ActiveRecord::RecordNotFound
        render json:
        {error: 'error'}, status: :not_found
    end

    def set_project
        @team = current_user.projects.find(params[:team_id])
    rescue ActiveRecord::RecordNotFound
        render json:
        {error: 'error'}, status: :not_found
    end

    def authorize_team_access
        unless current_user.teams.include?(@team)
            render json:
            {error: 'you shall not pass'}, status: :forbidden
        end
    end

    def authorize_project_access
        membership = @team.team_membership.find_by(user: current_user)
        unless @team.owner == current_user || membership&.role.in?(['admin', 'member'])
            render json:
            {error: 'you shall not pass'}, status: :forbidden
        end
    end

    def project_params
        params.require(:project).permit(:name,:description,:status)
    end

    def projects_json(projects)
        projects.map {|project| project_json(project)}
    end

    def project_json(project, include_tasks: false)
        result = {
            id: project.id,
            name: project.name,
            description: project.description,
            status: project.status,
            completion_percentage: project.completion_percentage,
            tasks_count: project.tasks.count,
            team: {
                id: project.team.id,
                name: project.team.name
            },
            created_at: project.created_at,
            updated_at: project.updated_at
        }

        if include_tasks
            result[:tasks] = project.tasks.includes(:assignee).map 
            {|task| task_json(task)}
        end

        result
    end

    def task_json(task)
        {
            id: task.id,
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            due_date: task.due_date,
            assignee: task.assignee ? user_json(task.assignee) : nil,
            overdue: task.overdue?,
            created_at: task.created_at
        }
    def

    def user_json(user)
        {id: user.id,
        name: user.name,
        email:user.email
    }
    end

    def pagination_json(collection)
        {
            current_page: collection.current_page,
            total_pages: collection.total_pages,
            total_coun: collection.total_count,
            per_page: collection.limit_value
        }
    end
end