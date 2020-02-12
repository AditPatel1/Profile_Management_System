class ApplicationController < ActionController::Base
  #protect_from_forgery with: :exception
  include ApplicationHelper

  before_action :authenticate_request

  attr_reader :current_user
  
  private

  def authenticate_request
    if cookies['user_auth_token'].present?
      user_auth_token = cookies['user_auth_token']
      @current_user = User.authenticate_using_redis(user_auth_token)
      if !@current_user
        respond_to do |format|
          format.json {
            render json: {
              error: 'Not Authorized, Login Again'
            }
          }
          format.html{
            redirect_to users_login_path, alert: 'Not Authorized, Please Login'
            }
        end
      end
      #render json: { error: 'Not Authorized, Login again' }, status: 401 unless @current_user
    else
      respond_to do |format|
          format.json {
            render json: {
              error: 'Not Authorized, Please Login'
            }
          }
          format.html{
              redirect_to users_login_path, alert: 'Not Authorized, Please Login'
          }
        end
    end
  	#if cookies['user_auth_token']
		  #user_auth_token = cookies['user_auth_token']
		  #@current_user = AuthorizeApiRequest.call(user_auth_token).result
          	#comment : #@current_user = AuthorizeApiRequest.call(request.headers).result
          	#if !@current_user
          		#redirect_to '/userauthenticationfailed'
    	#render json: { error: 'Not Authorized' }, status: 401 unless @current_user
	  #else
		  #redirect_to users_login_path
	  #end
  end
end
