class AppsController < ApplicationController

   def index
      # Get all apps
      auth = get_auth_object

      @apps = Array.new
      begin
         Dav::App.get_all_apps(auth).each do |app|
            @apps.push(app)
         end
      rescue StandardError => e
         flash.now[:danger] = replace_error_message(e.message)
         render 'index'
      end
   end
end