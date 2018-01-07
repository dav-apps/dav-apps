class UsersController < ApplicationController

   def login
      
   end

   def login_action
      @auth = Dav::Auth.new(api_key: ENV["DAV_API_KEY"], 
      secret_key: ENV["DAV_SECRET_KEY"],
      uuid: ENV["DAV_UUID"],
      environment: Rails.env)

      email = params[:email]
      password = params[:password]

      begin
         user = @auth.login(email, password)
         session[:jwt] = user.jwt
         puts user.jwt

         redirect_to root_path
      rescue StandardError => e
         flash.now[:danger] = e.message
         render 'login'
      end
   end

   def logout
      session[:jwt] = "";
   end

   def signup

   end

   def signup_action

   end
end