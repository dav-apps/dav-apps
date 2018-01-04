class StartsController < ApplicationController

  	def index
		session[:jwt] = "blablabla"
  	end
end
