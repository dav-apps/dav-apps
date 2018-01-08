class UsersController < ApplicationController

   def login
      
   end

   def login_action
      email = params[:email]
      password = params[:password]
      auth = get_auth_object

      begin
         user = auth.login(email, password)
         session[:jwt] = user.jwt
         session[:username] = user.username
         session[:user_id] = user.id

         redirect_to root_path
      rescue StandardError => e
         flash.now[:danger] = e.message
         render 'login'
      end
   end

   def logout
      session[:jwt] = nil
      session[:username] = nil
      session[:user_id] = nil
      flash[:success] = "You are now logged out. Have a nice day :)"
      redirect_to root_path
   end

   def signup

   end

   def signup_action
      username = params[:username]
      email = params[:email]
      password = params[:password]
      password_confirmation = params[:password_confirmation]
      auth = get_auth_object

      begin
         if password == password_confirmation
            auth.signup(email, password, username)

            flash[:success] = "Thanks for signing up! You will receive an email to confirm your account."
            redirect_to root_path
         else
            flash.now[:danger] = "The password confirmation does not match your password"
         render 'signup'
         end
      rescue StandardError => e
         flash.now[:danger] = e.message
         render 'signup'
      end
   end
end