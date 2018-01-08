class AppsController < ApplicationController

   def index
      # Get all apps
      auth = get_auth_object

      @apps = Array.new
      begin
         Dav::App.get_all_apps(session[:jwt]).each do |app|
            @apps.push(app)
         end
      rescue StandardError => e
         flash.now[:danger] = e.message
         render 'index'
      end
   end
end