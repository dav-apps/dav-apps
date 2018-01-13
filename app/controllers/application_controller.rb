class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	helper_method :get_auth_object, :logged_in?, :require_user, :login_implicit_page?

  	def get_auth_object
    	Dav::Auth.new(api_key: ENV["DAV_API_KEY"], 
							secret_key: ENV["DAV_SECRET_KEY"],
							uuid: ENV["DAV_UUID"],
							environment: Rails.env)
	end

	def logged_in?
		!session[:jwt].nil?
	end
	
	def require_user
		if !logged_in?
			flash[:danger] = "You need to be logged in to see this page."
			redirect_to root_path
		end
	end

	def clear_session
		session[:jwt] = nil
		session[:user_id] = nil
		session[:username] = nil
	end
end
