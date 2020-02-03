class UsersController < ApplicationController
	skip_before_action :authenticate_request, only: [:new, :create, :get_login, :post_login]
	include UserHelper


	def new
		@user = User.new
	end

	def get_login
	end

	def post_login
		#render plain: 'You are logged in'
		user_auth_token = cookies['user_auth_token']
		auth_token = User.redis_key_generate(params[:email], params[:password], user_auth_token)
		#user_auth_token = AuthenticateUser.call(params[:email], params[:password])
		#byebug
		#response.headers['Authorization'] = "JWT #{auth_token.result}"
		if !auth_token
			render plain: 'Error. Cannot login, wrong credentials'
		else
			user_id = Rails.cache.read(auth_token,namespace:'cache')
			@current_user = get_user_object(user_id)
			if @current_user.status == 'inactive'
				render plain: 'User Deactivated'
			else
				if auth_token
					response.set_cookie "user_auth_token", "#{auth_token}"
					render json: {
						Profile_ID: @current_user.id,
						Name: @current_user.name,
						Email: @current_user.email,
						Phone_No: @current_user.phone_no,
						Parent_id: @current_user.parent_id,
						Address: @current_user.address,
						Profile_type: @current_user.profile_type,
						Birth_date: @current_user.birth_date,
						About_Me: @current_user.about_me,

						message: 'Successfully logged in'
					}
					#redirect_to users_get_profile_path
				else
					render plain: "Error in login"
					#redirect_to users_login_path
				end
			end
		end
		#if command.success?
			#response.headers['Authorization'] = "JWT #{command.result}"
			#render json: { auth_token: command }#.result }
			#else
			#render json: { error: command.errors }, status: :unauthorized
		#end
	end

	def get_profile
		#@user = get_user_profile(params[:profile_id])
		@user = get_user_profile(@current_user.id)
		render json: {
			Profile_ID: @user.id,
			Name: @user.name,
			Email: @user.email,
			Phone_No: @user.phone_no,
			Parent_id: @user.parent_id,
			Address: @user.address,
			Profile_type: @user.profile_type,
			Birth_date: @user.birth_date,
			About_Me: @user.about_me
		}
		#@user = Rails.cache.read(@current_user.id)
		#byebug
		#render :json => @current_user
	end

	def edit
		#@user = Rails.cache.read(@current_user.id)
		#if @user == nil
			#@user = User.find_by(id: @current_user.id)
		#end
	end

	def show
		#@user = User.find_by(id: params[id])
		render plain: 'Hello'
	end

	def create
		@user = User.new(user_params)
		if @user.save
			render json: {
				Profile_ID: @user.id,
				Message: 'Successfully signed up'
			}
			#redirect_to users_login_path
			#redirect_to user_path(@user)
		else
			render json: {
				message: @user.errors.full_messages.to_sentence
				}
		end
		#if(params[:password] == params[:re_enter_password])
		#	@user = User.new(user_params)
		#	if @user.save
		#		render plain: params[:re_enter_params]
				#redirect_to @user
		#	else
		#		render plain: 'You need to sign up again'
		#		link_to 'Signup', new_user_path
		#	end
		#else
		#	redirect_to new_user_path
		#end
	end

	def update
		if update_user(@current_user.id,user_params)
			redirect_to users_get_profile_path
		else
			#flash[:error] = "Incorrect Inputs"
			redirect_to edit_user_path(@current_user)
		end
=begin
		if @current_user.update(user_params)
			Rails.cache.delete(@current_user.id, namespace: "cache")
			redirect_to users_get_profile_path
		else
			#flash[:error] = "Incorrect Inputs"
			redirect_to edit_user_path(@current_user)
		end
=end
	end


	def logout
		#cookies.delete :user_auth_token
		Rails.cache.delete(cookies['user_auth_token'], namespace: "cache")
		@current_user = nil
		redirect_to users_login_path
	end

	private
		def user_params
			params.require(:user).permit(:name, :email, :password, :phone_no, :birth_date, :address, :about_me, :profile_type)
		end
end
