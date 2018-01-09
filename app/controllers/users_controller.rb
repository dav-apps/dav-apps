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

            flash[:success] = "Thanks for signing up! You will receive an email to activate your account."
            redirect_to root_path
         else
            flash.now[:danger] = "The password confirmation does not match your password."
            render 'signup'
         end
      rescue StandardError => e
         flash.now[:danger] = e.message
         render 'signup'
      end
   end

   def password_reset

   end

   def password_reset_action
      email = params[:email]

      begin
         if email
            Dav::User.send_reset_password_email(email)

            flash[:success] = "You will receive an email to reset your password."
            redirect_to root_path
         end
      rescue StandardError => e
         flash.now[:danger] = e.message
         render 'password_reset'
      end
   end

   def reset_password
      @password_confirmation_token = params[:password_confirmation_token]
   end

   def reset_password_action
      password_confirmation_token = params[:password_confirmation_token]
      password = params[:password]
      password_confirmation = params[:password_confirmation]
      auth = get_auth_object

      begin
         if password.length > 0 && password_confirmation.length > 0
            if password == password_confirmation
               Dav::User.set_password(password_confirmation_token, password)

               flash[:success] = "Your password was updated successfully."
               redirect_to root_path
            else
               flash.now[:danger] = "The password confirmation does not match your password."
               render 'reset_password'
            end
         else
            render 'reset_password'
         end
      rescue StandardError => e
         if e.message.include?("1203")
            flash[:danger] = "There was an error. Please try again."
            redirect_to root_path
         else
            flash.now[:danger] = e.message
            render 'reset_password'
         end
      end
   end

   def resend_activation_email

   end

   def resend_activation_email_action
      email = params[:email]

      if email.length < 1
         render 'resend_activation_email'
      else
         begin
            Dav::User.send_verification_email(email)
   
            flash[:success] = "You should now receive another activation email."
            redirect_to root_path
         rescue StandardError => e
            flash.now[:danger] = e.message
            render 'resend_activation_email'
         end
      end
   end
end