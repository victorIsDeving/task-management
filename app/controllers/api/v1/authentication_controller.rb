class Api::V1::AuthenticationController < Api::V1::BaseController
    skip_before_action :authenticate_request, only: [:login, :register]

    def login
        user = User.find_by(email: params[:email]&downcase)

        if user&.authenticate(params[:password])
            token = generate_token(user)
            render json: {
                data: {
                    user: user_json(user),
                    token: token
                },
                message: 'Login successful'
            }, status: :ok
        else
            render json: { error: 'Invalid email or password' }, status: unauthorized
        end
    end

    def register
        puts "Debug #{params.inspect}"
        user = User.new(user_params)
        user.email = user.email&.downcase

        if user.save
            token = generate_token(user)
            render json: {
                data: {
                    user: user_json(user),
                    token: token
                },
                message: 'Successful'
            }, status: :created
        else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def me
        render json: {
            data: {
                user: user_json(current_user)
            }
        }, status: :ok
    end

    private

    def user_params
        params.require(:authentication).permit(:name, :email, :password, :password_confirmation)
    end

    def generate_token(user)
        payload = {
            user_id: user.id,
            exp: 24.hours.from_now.to_i
        }
        JWT.encode(payload, Rails.application.secret_key_base)
    end

    def user_json(user)
        {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role
        }
    end

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
            render json: { error: 'Authorization header missing' }, status: :unauthorized
        end
    end

    def current_user
        @current_user
    end
end