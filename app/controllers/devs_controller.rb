class DevsController < ApplicationController

	def index
		@dev = Dav::Dev.get(session[:jwt])
	end

	def show
		@app = Dav::App.get(session[:jwt], params[:id])
	end

	def show_table
		@table = Dav::Table.get(session[:jwt], params[:id], params[:name])
		puts @table.name
	end

	def show_event
		@event = Dav::Event.get_by_name(session[:jwt], params[:name])
	end
end