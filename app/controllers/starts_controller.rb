class StartsController < ApplicationController

	def index
		if session[:jwt]
			# Get user object
			auth = get_auth_object

			begin
				@user = Dav::User.get(session[:jwt], session[:user_id])
			rescue StandardError => e
				flash.now[:danger] = replace_error_message(e.message)
				render 'index'
			end
		end
	end
	
	def privacy

	end

	def contact

	end

	def pricing

	end
end
