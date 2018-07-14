class UsersController < ApplicationController

   before_action :require_user, only: [:show]

   def login
      
   end

   def login_action
      email = params[:email]
      password = params[:password]
		auth = get_auth_object

      begin
         user = auth.login(email, password)
         set_session(user)
         
         log("login")
         redirect_to root_path
      rescue StandardError => e
         flash.now[:danger] = replace_error_message(e.message)
         render 'login'
      end
   end

   def login_implicit
      api_key = params[:api_key]
      redirect_url = params[:redirect_url]
      auth = get_auth_object

      if !api_key || !redirect_url
         flash[:danger] = "There was an error. Please try again."
         redirect_to root_path
      else
         if session[:jwt]
            @user = Dav::User.get_by_jwt(session[:jwt])
         end

         session[:api_key] = api_key
         session[:redirect_url] = redirect_url
      end
   end

   def login_implicit_action
      api_key = session[:api_key]
      redirect_url = session[:redirect_url]

      email = params[:email]
      password = params[:password]
      
      if params[:current_user]
         # Logged in user was clicked, redirect to app
         # Check if the user is logged in on the website
         begin
            user = Dav::Auth.login_by_jwt(session[:jwt], api_key)

            log("login_implicit")
            redirect_to "#{redirect_url}?jwt=#{user.jwt}"
         rescue StandardError => e
            session[:api_key] = api_key
            session[:redirect_url] = redirect_url
         end
      else
         # Another user has logged in
         begin
            auth = get_auth_object
            
            user = auth.login(email, password)
            set_session(user)
   
            dev = Dav::Dev.get_by_api_key(auth, api_key)
            dev_auth = Dav::Auth.new(api_key: dev.api_key, 
                                    secret_key: dev.secret_key,
                                    uuid: dev.uuid,
                                    environment: Rails.env)
            user2 = dev_auth.login(email, password)
   
            session[:api_key] = nil
				session[:redirect_url] = nil
				log("login_implicit")
            
            redirect_to "#{redirect_url}?jwt=#{user2.jwt}"
         rescue StandardError => e
            flash[:danger] = replace_error_message(e.message)
            redirect_to login_implicit_path + "?api_key=#{api_key}&redirect_url=#{CGI.escape(redirect_url)}"
         end
      end
   end

   def logout
      clear_session
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
				log("signup")

            flash[:success] = "Thanks for signing up! You will receive an email to activate your account."
            redirect_to root_path
         else
            flash.now[:danger] = "The password confirmation does not match your password."
            render 'signup'
         end
      rescue StandardError => e
         flash.now[:danger] = replace_error_message(e.message)
         render 'signup'
      end
   end

   def show
      @user = Dav::User.get(session[:jwt], session[:user_id])
		@avatar_url = ENV["DAV_BLOB_STORAGE_BASE_URL"] + @user.id.to_s + ".png"
   end

   def update
      auth = get_auth_object
      @user = Dav::User.get(session[:jwt], session[:user_id])
      username = params[:username]
      email = params[:email]
      password = params[:password]
      password_confirmation = params[:password_confirmation]
      app_id = params[:app_id]
      avatar = params[:avatar]
      delete_account = params[:delete_account]
      create_archive = params[:create_archive]
		archive_id = params[:archive_id]
		update_payment_info = params[:update_payment_info]
		upgrade_plus = params[:upgrade_plus]
		downgrade_free = params[:downgrade_free]

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
            rescue StandardError => e
               flash[:danger] = replace_error_message(e.message)
				end
				redirect_to user_path
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
            rescue StandardError => e
               flash[:danger] = replace_error_message(e.message)
				end
				redirect_to user_path
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
            rescue StandardError => e
               flash[:danger] = replace_error_message(e.message)
				end
				redirect_to user_path
         end
      end

      if app_id
         # Remove app data
         begin
            @user.remove_app(app_id)
            flash[:success] = "The app was successfully removed!"
         rescue StandardError => e
            flash[:danger] = replace_error_message(e.message)
			end
			redirect_to user_path(anchor: "apps")
      end

      if delete_account
         begin
            Dav::User.send_delete_account_email(@user.email)
            flash[:success] = "You will receive an email to delete your account."
         rescue StandardError => e
            flash[:danger] = replace_error_message(e.message)
			end
			redirect_to user_path
      end

      if avatar
			begin
            if File.size(avatar.tempfile) < 5000000
               file = File.open(avatar.tempfile, "rb")
               contents = Base64.encode64(file.read)

               @user.update({avatar: contents})
               flash[:success] = "Avatar was successfully uploaded. It may take some time to update across the site and your apps."
               redirect_to user_path
            else
               flash[:danger] = "The file is too large."
               redirect_to user_path
            end
         rescue StandardError => e
            flash[:danger] = replace_error_message(e.message)
            redirect_to user_path
         end
      end
      
      if create_archive
         begin
            archive = Dav::Archive.create(@user.jwt)
            
            flash[:success] = "You will get an email when your archive is ready."
         rescue StandardError => e
            flash[:danger] = replace_error_message(e.message)
			end
			redirect_to user_path(anchor: "archives")
      end

      if archive_id
         # Remove the archive
         begin
            archive = Dav::Archive.get(@user.jwt, archive_id)
            archive.delete(@user.jwt)
   
            flash[:success] = "The archive was successfully deleted."
         rescue StandardError => e
            flash[:danger] = replace_error_message(e.message)
			end
			redirect_to user_path(anchor: "archives")
		end

		if update_payment_info == "true"
			begin
				@user.update({payment_token: params["stripeToken"]})

				flash[:success] = "Your payment info was successfully updated"
			rescue StandardError => e
				flash[:danger] = replace_error_message(e.message)
			end
			redirect_to user_path(anchor: "plans")
		end
		
		if upgrade_plus == "true"
			begin
            # Send a request to the api to update the plan
            @user.update({payment_token: params["stripeToken"], plan: 1})

				flash[:success] = "Your successfully upgraded to Plus"
			rescue StandardError => e
				flash[:danger] = replace_error_message(e.message)
			end
			redirect_to user_path(anchor: "plans")
		end

		if downgrade_free
			begin
				@user.update({plan: 0})

				flash[:success] = "Your plan was successfully changed"
			rescue StandardError => e
				flash[:danger] = replace_error_message(e.message)
			end
			redirect_to user_path(anchor: "plans")
		end
      
		if !username && !email && !password && !password_confirmation && 
			!app_id && !delete_account && !avatar && !create_archive && 
			!archive_id && !update_payment_info && !upgrade_plus && !downgrade_free

         redirect_to user_path
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
         flash.now[:danger] = replace_error_message(e.message)
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
            flash.now[:danger] = replace_error_message(e.message)
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