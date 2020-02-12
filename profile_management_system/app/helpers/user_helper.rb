module UserHelper

	def get_user_profile(user_id)
		get_user_object(user_id)
	end
	def update_user(user_id,user_params)
		@user = get_user_object(user_id)
		if @user.update(user_params)
			flash[:success] = 'Profile updated successfully'
			@user = User.find_by(id: user_id)
			Rails.cache.write(user_id,@user,namespace: 'cache')
			return true
		else
			flash[:error] = 'Profile not updated'
			flash[:alert] = @user.errors.full_messages.to_sentence
			return false
		end
	end


	def get_user_object(user_id)
		user = Rails.cache.read(user_id,namespace: 'cache')
		if user
			return user
		else
			user = User.find_by(id: user_id)
			Rails.cache.write(user_id,user,namespace: 'cache', expires_in: 1.day)
			return user
		end
	end

	def is_logged_in
		user_auth_token = cookies['user_auth_token']
		#below check is when user is already logged in, and when it tries to go to login page, he will be redirected to his profile
		if user_auth_token
			if Rails.cache.read(user_auth_token, namespace: 'cache')
				flash[:notice] = "You are already logged in. If you want to create new account or sign in from another account, first logout!"
				redirect_to users_get_profile_path
			end
		end
	end

end
