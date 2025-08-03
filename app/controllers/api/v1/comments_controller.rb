class Api::V1::CommentsController < Api::V1::BaseController
    before_action :set_team_project_and_task
    before_action :set_comment, only: [:uppdate, :destroy]
    before_action :authorize_team_access
    before_action :authorize_comment_owner, only: [:update, :destroy]

    def index
        @comments = @task.comments.includes(:user).recent
            .page(params[:page])
            .per(params[:per_page] || 20)

        render_sucess({
            comments: comments_json(@comments),
            pagination: pagination_json(@comments)
        })
    end

    def create
        @comment = @task.comments.build(comment_params)
        @comment.user = current_user

        if @comment.save
            render_success(
                comment_json(@comment),
                'success',
                :created
            )
        else 
            render_error(@comment)
        end
    end

    def update
        if @comment.update(comment_params)
            render_success(
                comment_json(@comment),
                'success'
            )
        else
            render_error(@comment)
        end
    end

    def destroy
        @comment.destroy
        render_success(nil, 'success')
    end

    private

    def set_team_project_and_task
        @team = current_user.teams.find(params[:team_id])
        @project = @team.projects.find(params[:project_id])
        @task = @project.tasks.find(params[:task_id])
    rescue ActiveRecord::RecordNotFound
        render json:
        {error: 'not found'}, status: :not_found
    end

    def set_comment
        @comment = @task.comments.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json:
        {error> 'not found'}, status: :not_found
    end

    def authorize_comment_owner
        unless @comment.user == current_user || current_user.admin?
            render json:
            {error: 'only edit your own comments'}, status: :forbidden
        end
    end

    def comments_json(comments)
        params.require(:comment).permit(:contet)
    end

    def comment_json(comment)
        {
            id: comment.id,
            content: comment.content,
            user: user_json(comment.user),
            task_id: comment.task_id,
            created_at: comment.created_at,
            updated_at: comment.updated_at
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
