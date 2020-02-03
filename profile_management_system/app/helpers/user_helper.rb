module UserHelper

	def get_user_profile(user_id)
		get_user_object(user_id)
	end
	def update_user(user_id,user_params)
		@user = get_user_object(user_id)
		if @user.update(user_params)
			@user = User.find_by(id: user_id)
			Rails.cache.write(user_id,@user,namespace: 'cache')
			return true
		else
			flash.alert = "Edit unsuccessful"
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

end
