class UsersController < ApplicationController

   before_action :require_user, only: [:show, :settings]

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

   def show
      @user = Dav::User.get(session[:jwt], session[:user_id])
   end

   def update
      auth = get_auth_object
      @user = Dav::User.get(session[:jwt], session[:user_id])
      username = params[:username]
      email = params[:email]
      password = params[:password]
      password_confirmation = params[:password_confirmation]
      app_id = params[:app_id]
      delete_account = params[:delete_account]

      if username
         if username == @user.username
            redirect_to user_path
         elsif username.length < 1
            redirect_to user_path
         else
            # Update username
            begin
               @user.update({username: username})
               flash[:success] = "Your new username was saved successfully!"
               redirect_to user_path
            rescue StandardError => e
               flash[:danger] = e.message
               redirect_to user_path
            end
         end
      end

      if email
         if email == @user.email
            redirect_to user_path
         elsif email.length < 1
            redirect_to user_path
         else
            # Update email
            begin
               @user.update({email: email})
               flash[:success] = "We sent you an email to your new email address to confirm it."
               redirect_to user_path
            rescue StandardError => e
               flash[:danger] = e.message
               redirect_to user_path
            end
         end
      end

      if password || password_confirmation
         if password.length < 1 && password_confirmation.length < 1
            redirect_to user_path
         elsif password.length < 5
            flash[:danger] = "Your new password is too short."
            redirect_to user_path
         elsif password != password_confirmation
            flash[:danger] = "Your new password does not match your password confirmation."
            redirect_to user_path
         else
            # Update password
            begin
               @user.update({password: password})
               flash[:success] = "You will receive an email to confirm your new password."
               redirect_to user_path
            rescue StandardError => e
               flash[:danger] = e.message
               redirect_to user_path
            end
         end
      end

      if app_id
         # Remove app data
         begin
            @user.remove_app(app_id)
            flash[:success] = "The app was successfully removed!"
            redirect_to user_path + "#apps"
         rescue StandardError => e
            flash[:danger] = e.message
            redirect_to user_path + "#apps"
         end
      end

      if delete_account
         begin
            Dav::User.send_delete_account_email(@user.email)
            flash[:success] = "You will receive an email delete your account."
            redirect_to user_path
         rescue StandardError => e
            flash[:danger] = e.message
            redirect_to user_path
         end
      end
   end


   # Dev routes
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

   def confirm_user
      id = params[:id]
      email_confirmation_token = params[:email_confirmation_token]

      begin
         Dav::User.confirm(id, email_confirmation_token)

         flash[:success] = "Your account was successfully activated!"
         redirect_to root_path
      rescue StandardError => e
         flash[:danger] = "There was an error. Please try again."
         redirect_to root_path
      end
   end

   def change_email
      email_confirmation_token = params[:email_confirmation_token]
      id = params[:id]

      begin
         Dav::User.save_new_email(id, email_confirmation_token)

         flash[:success] = "Your email was successfully changed!"
         redirect_to root_path
      rescue StandardError => e
         flash[:danger] = "There was an error. Please try again."
         redirect_to root_path
      end
   end

   def change_password
      password_confirmation_token = params[:password_confirmation_token]
      id = params[:id]

      begin
         Dav::User.save_new_password(id, password_confirmation_token)

         flash[:success] = "Your password was successfully changed!"
         redirect_to root_path
      rescue StandardError => e
         flash[:danger] = "There was an error. Please try again."
         redirect_to root_path
      end
   end

   def reset_new_email
      id = params[:id]

      begin
         Dav::User.reset_new_email(id)

         flash[:success] = "Your account now uses your previous email again."
         redirect_to root_path
      rescue StandardError => e
         flash[:danger] = "There was an error. Please try again."
         redirect_to root_path
      end
   end

   def delete_account
      user_id = params[:id]
      email_confirmation_token = params[:email_confirmation_token]
      password_confirmation_token = params[:password_confirmation_token]

      begin
         Dav::User.delete(user_id, email_confirmation_token, password_confirmation_token)

         clear_session
         flash[:success] = "Your account was successfully deleted."
         redirect_to root_path
      rescue StandardError => e
         flash[:danger] = "There was an error. Please try again."
         redirect_to root_path
      end
   end
end