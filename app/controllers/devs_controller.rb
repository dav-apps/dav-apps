class DevsController < ApplicationController

	def index
		@dev = Dav::Dev.get(session[:jwt])
	end

	def show
		@app = Dav::App.get(session[:jwt], params[:id])
	end

	def create_table
		name = params[:name]

		begin
			table = Dav::Table.create(session[:jwt], name, params[:id])
			redirect_to show_app_path(params[:id])
		rescue StandardError => e
			flash[:danger] = replace_error_message(e.message)
			redirect_to show_app_path(params[:id])
		end
	end

	def show_table
		@table = Dav::Table.get(session[:jwt], params[:id], params[:name])
		puts @table.name
	end

	def show_event
		@event = Dav::Event.get_by_name(session[:jwt], params[:name])
		sort_by = params["sort_by"]

		@sorted_logs = Hash.new
		@event.logs.each do |log|
			log_date = log["created_at"].to_date

			if sort_by == "year"
				date = "#{log_date.year}"
			elsif sort_by == "month"
				date = "#{log_date.strftime("%B")} #{log_date.year}"
			else
				# Amerikanische Schreibweise: MM.DD.YY
				date = "#{log_date.month}.#{log_date.day}.#{log_date.year}"
			end

			if @sorted_logs[date]	# If the date exists, add one to the value of the date
				@sorted_logs[date] = @sorted_logs[date] + 1
			else
				@sorted_logs[date] = 1
			end
		end
	end
end