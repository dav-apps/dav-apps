class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	helper_method :get_auth_object, :logged_in?, :require_user, :login_implicit_page?, :percentage_of, :bytes_to_gigabytes, :log

  	def get_auth_object
    	Dav::Auth.new(api_key: ENV["DAV_API_KEY"], 
							secret_key: ENV["DAV_SECRET_KEY"],
							uuid: ENV["DAV_UUID"],
							environment: Rails.env)
	end

	def percentage_of(a, b)
		(a.to_f / b.to_f) * 100.0
	end

	def bytes_to_gigabytes(bytes)
		(bytes.to_f / 1000.0 / 1000.0 / 1000.0).round
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

	def set_session(user)
		session[:jwt] = user.jwt
		session[:user_id] = user.id
		session[:username] = user.username
	end

	def log(event_name)
		if event_name == "visit"
			if session[:ip] == nil || session[:ip] != request.remote_ip
				session[:ip] = request.remote_ip
				
				begin
					Dav::Event.log(get_auth_object, ENV["DAV_APPS_APP_ID"], event_name)
				rescue Exception => e
					puts e.message
				end
			end
		else
			begin
				Dav::Event.log(get_auth_object, ENV["DAV_APPS_APP_ID"], event_name)
			rescue Exception => e
				puts e.message
			end
		end
   end

	def replace_error_message(error)
		if error.include?("2801") || error.include?("1201")
			"Login was not possible"
		elsif error.include?("1202")
			"You can't log in before you activated your account"
		elsif error.include?("1301") || error.include?("1302") || error.include?("1303")
			flash[:danger] = "Your session expired. Please log in again."
			redirect_to logout_path
		elsif error.include?("2201")
			"Your username is too short"
		elsif error.include?("2401")
			"Your email address is not valid"
		elsif error.include?("2701")
			"This username is already taken"
		elsif error.include?("2702")
			"This email is already being used by another user"
		elsif error.include?("2201")
			"Your username is too short"
		elsif error.include?("2202")
			"Your password is too short"
		elsif error.include?("2203")
			"The name is too short"
		elsif error.include?("2204")
			"The description is too short"
		elsif error.include?("2205")
			"The table name is too short"
		elsif error.include?("2301")
			"Your username is too long"
		elsif error.include?("2302")
			"Your password is too long"
		elsif error.include?("2303")
			"The name is too long"
		elsif error.include?("2304")
			"The description is too long"
		elsif error.include?("2305")
			"The table name is too long"
		elsif error.include?("2501")
			"The table name contains not allowed characters"
		elsif error.include?("1203") || error.include?("1204")
			"There was an error. Please try again."
		else
			error
		end
	end
end
