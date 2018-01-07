class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	helper_method :get_auth_object

  	def get_auth_object
    	Dav::Auth.new(api_key: ENV["DAV_API_KEY"], 
							secret_key: ENV["DAV_SECRET_KEY"],
							uuid: ENV["DAV_UUID"],
							environment: Rails.env)
  	end
end
