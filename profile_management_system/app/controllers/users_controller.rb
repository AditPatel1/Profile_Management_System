class UsersController < ApplicationController

	#authenticate_request authenticates user reuests before accessing apis which need login
	#get_login,post_login.new,create methods are accessible without login so the action is skipped
	skip_before_action :authenticate_request, only: [:index, :new, :create, :get_login, :post_login]

	#helper method for get_profile of users and update for user profile
	include UserHelper

	def index
		is_logged_in
	end
	#new method is called when user creats a profile i.e. when signup is done, view of create profile is rendered
	def new
		@user = User.new
	end

	#'POST' method after user enters parameters in form for SIGNUP
	def create
		@user = User.new(user_params)
		#user_params are defined as a private method at the bottom which tells which params are permitted
		if @user.save
			respond_to do |format|
				format.json {
					render json: {
						Profile_ID: @user.id,
						Message: 'Successfully signed up'
					}
				}
				#on successful signup. API response is Json which consists of Profile ID and successfully signed up msg
				format.html {
					flash[:success] = 'Successfully signed up, You can login now'
					redirect_to users_login_path
					#redirect_to user_path(@user)
				}
			end
		else
			respond_to do |format|
				format.json {
					render json: {
						error: @user.errors.full_messages.to_sentence,
						message: 'SIgn Up unsuccessful'
					}
				}
				format.html {
					flash.alert = 'Signup unsuccessful. Please check the below fields'
					flash[:error] = @user.errors.full_messages.to_sentence
					redirect_to new_user_path
				}
			end
		end
	end

	#'GET' method to render the form for login for user in website
	def get_login
		is_logged_in
	end

	#'POST' method after user enters credentials
	def post_login
		auth_token = User.redis_key_generate(params[:email_or_phone_no], params[:password])
			#user_auth_token = AuthenticateUser.call(params[:email], params[:password])
			#response.headers['Authorization'] = "JWT #{auth_token.result}"
		if auth_token == 404 || auth_token == 401     
		#401 denotes wrong password, 404 denotes 'cannot find user in database'
			respond_to do |format|
				format.json {
					if auth_token == 401
						render json: {
							error: 'Incorrect login credentials'
						}, status: 401
					else
						render json: {
							error: 'User doesnot exist'
						}, status: 404
					end
				}
				format.html {
					if auth_token == 401
						flash[:error] = 'Password incorrect. Please login again'
					else
						flash[:error] = 'User doesnot exist'
					end
					redirect_to users_login_path
				}
			end
		else
			user_id = Rails.cache.read(auth_token,namespace:'cache')
			@current_user = get_user_object(user_id)
			if @current_user.status == 'inactive'
				respond_to do |format|
					format.json {
						render json: {
							message: 'User Deactivated'
						}
					}
					format.html {
						flash[:notice] = 'User Deactivated. Please contact administrator for more details.'
						redirect_to users_login_path
					}
				end
			else
				response.set_cookie 'user_auth_token', "#{auth_token}"
				respond_to do |format|
					format.json {
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
					}
					format.html {
						redirect_to users_get_profile_path, success: 'Successfully logged in'
					}
				end
			end
		end
	end

	def get_profile
		@user = get_user_profile(@current_user.id)
		respond_to do |format|
			format.json {
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
			}
			format.html {
			}
		end
	end

	def edit
		#@user = Rails.cache.read(@current_user.id)
		#if @user == nil
			#@user = User.find_by(id: @current_user.id)
		#end
	end

	def update
		if update_user(@current_user.id,user_params)
			redirect_to users_get_profile_path
		else
			redirect_to edit_user_path(@current_user)
		end
	end


	def logout
		Rails.cache.delete(cookies['user_auth_token'], namespace: "cache")
		cookies.delete :user_auth_token, domain: 'localhost'
		@current_user = nil
		flash[:success] = 'Logged out successfully'
		redirect_to users_login_path
	end

	private
		def user_params
			params.require(:user).permit(:name, :email, :password, :phone_no, :birth_date, :address, :about_me, :profile_type)
		end
end
