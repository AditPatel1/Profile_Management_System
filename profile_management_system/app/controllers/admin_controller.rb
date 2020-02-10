class AdminController < ApplicationController

	#authenticate_request authenticates user reuests before accessing apis which need login
	#it is skipped here for admin controller methods
	skip_before_action :authenticate_request

	#authenticate_admin authenticates admin requests for admin login requiring methods
	before_action :authenticate_admin, except: [:get_login, :post_login]

	include UserHelper

	def get_login
	end

	def post_login
		admin_auth_token = AuthenticateAdmin.call(params[:username], params[:password])
		response.set_cookie "admin_auth_token", "#{admin_auth_token.result}"
		redirect_to admin_index_path
	end
	


	#Index page for admin when they are successfully logged in
	#The view greets admin and gives options for creating, searhing users
	#It also has a button for admin to logout and view daily reports of user created..
	def index
		#render plain: "Hey admin"
	end

	def get_user
		@user = get_user_profile(params[:user_id])
	end

	def daily_reports
		render file: 'daily_report_of_users.txt', layout: false, content_type: 'text/plain'
	end

	def edit_user
		@user = get_user_object(params[:user_id])
=begin
		@user = Rails.cache.read(params[:user_id], namespace: 'cache')
		if !@user
			@user = User.find_by(id: params[:user_id])
			Rails.cache.write(@user.id, @user, namespace: 'cache', expires_in: 1.day)
		end
=end
	end

	def create_user_view
		@user = User.new
	end

	def create_user
		@user = User.new(user_params)
		if @user.save
			redirect_to admin_get_user_path(:user_id => @user.id)
			#redirect_to user_path(@user)
		else
			render json: {
				message: @user.errors.full_messages.to_sentence
				}
		end
	end

	def update
		user_id = user_params[:id]
		if update_user(user_id,user_params)
			redirect_to admin_get_user_path(:user_id => user_id)
		else
			render :json => @user.errors
			#redirect_to admin_edit_user_path(:user_id => user_id)
		end

	end

	def search
		if params[:query].nil?
		else
			@users = User.search(params)
		end
	end

	def change_status
		if (params[:status] == 'active')
			update_user(params[:user_id], status: 'inactive')
		else
			update_user(params[:user_id], status: 'active')
		end
		redirect_to admin_get_user_path(:user_id => params[:user_id])
	end

	def logout
		#response.set_cookie "admin_auth_token", ""
		cookies.delete :admin_auth_token, domain: 'localhost'
		@current_admin = nil
		redirect_to admin_path
	end

	private
	def authenticate_admin
		admin_auth_token = cookies['admin_auth_token']
		decoded_admin_auth_token ||= JsonWebToken.decode(admin_auth_token)
		@current_admin ||= Admin.find(decoded_admin_auth_token[:admin_id]) if decoded_admin_auth_token
		render json: { error: 'Not Authorized' }, status: 401 unless @current_admin
		#byebug
	end

	def user_params
		params.require(:user).permit(:id, :name, :email, :password, :phone_no, :birth_date, :address, :about_me, :profile_type, :parent_id)
	end
end
