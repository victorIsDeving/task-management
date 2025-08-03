class Api::V1::BaseController < ApplicationController
    before_action :authenticate_request

    private

    def authenticate_request
        header = request.headers['Authorization']
        if header.present?
            token = header.split(' ').last
            begin
                decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
                @current_user = User.find(decoded['user_id'])
            rescue JWT::DecodeError, ActiveRecord::RecordNotFound
                render json: { error: 'Unauthorized' }, status: :unauthorized
            end
        else
            render json: { error: 'Authorization header required'}, status: :unauthorized
        end
    end

    def current_user
        @current_user
    end

    def render_error(resource, status = :unprocessable_entity)
        render json: { errors: resource.errors.full_messages }, status: status
    end

    def render_success(data, message = nil, status = :ok)
        response = { data: data }
        response[:message] = message if message
        render json: response, status: status
    end
end