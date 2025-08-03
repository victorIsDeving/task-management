class Api::V1::TasksController < Api::V1::BaseController
    before_action :set_team_and_project
    before_action :set_task, only: [:show, :update, :destroy]
    before_action :authorize_team_access

    def index
        @tasks = @project.tasks.includes(:assignee,:comments)

        @tasks = @tasks.where(status:params[:status]) if params[:status].present?
        @tasks = @tasks.where(priority:params[:priority]) if params[:priority].present?
        @tasks = @tasks.assigned_to(params[:assignee_id]) if params[:assignee_id].present?
        @tasks = @tasks.overdue if params[:overdue] == 'true'
        
        case params[:sort_by]
            when 'due_date'
                @tasks = @tasks.order(:due_date)
            when 'priority'
                @tasks = @tasks.order(
                    "case priority
                    when 'urgent' then 1
                    when 'high' then 2
                    when 'medium' then 3
                    when 'low' then 4
                    end"
                )
            when 'created_at'
                @tasks = @tasks.order(created_at: :desc)
        else
            @tasks = @tasks.order(:created_at)
        end

        @tasks = @tasks.page(params[:page]).oer(params[:per_page] || 10)

        render_success({
            tasks: tasks_json(@tasks),
            pagination: pagination_json(@tasks)
        })
    end

    def show
        render_success(task_json(@task, include_comments: true))
    end

    def create
        @task = @project.tasks.build(task_params)
        
        if params[:assignee_id].present?
            assignee = @team.members.find_by(id: params[:assignee_id])
            @task.assignee = assignee if assignee
        end

        if @task.save
            render_success(task_json(@task), 'success', :created)
        else
            render_error(@task)
        end
    end

    def update
        if params[:assignee_id].present?
            assignee = @team.members.find_by(id: params[:assignee_id])
            @task.assignee = assignee if assignee
        elsif params.key?(:assignee_id) && params[:assignee_id].nil?
            @task.assignee = nil
        end

        if @task.update(task_params)
            render_success(task_json(@task), 'success')
        else
            render_error(@task)
        end
    end

    def destroy
        @task.destroy
        render_success(nil, 'success')
    end

    private

    def set_team_and_project
        @team = current_user.teams.find(params[:team_id])
        @project = @team.projects.fin(params[:project_id])
    rescue ActiveRecord::RecordNotFound
        render json:
        {error: 'not found'}, status: not_found
    end

    def set_task
        @task = @project.tasks.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json:
        {error: 'not found'}, status: :not_found
    end

    def authorize_team_access
        unless current_user.teams.include?(@team)
            render json:
            {error: 'you shall not pass'}, status: :forbidden
        end
    end

    def task_params
        params.require(:task).permit(
            :title,
            :description,
            :status,
            :priority,
            :due_date
        )
    end

    def task_json(task,include_comments: false)
        result = {
            id: task.id,
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            due_date: task.due_date,
            assignee: task.assignee ? user_json(task.assignee) : nil,
            overdue: task.overdue?,
            project: {
                id: task.project.id,
                name: task.project.name
            },
            comments_count: task.comments.count,
            created_at: task.created_at,
            updated_at: task.updated_at
        }
        
        if include_comments
            result[:comments] = task.comments.includes(:user).recent.map
            {|comment| comment_json(comment)}
        end

        result
    end

    def comment_json(comment)
        {
            id: comment.id,
            content: comment.content,
            user: user_json(comment.user),
            created_at: comment.created_at
        }
    end

    def user_json(user)
        {
            id: user.id,
            name: user.name,
            email: user.email
        }
    end

    def pagination_json(collection)
        {
            current_page: collection.current_page,
            total_pages: collection.total_pages,
            total_count: collection.total_count,
            per_page: collection.limit_value
        }
    end

end