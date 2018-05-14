class DevsController < ApplicationController

	before_action :require_user

	def index
		begin
			@dev = Dav::Dev.get(session[:jwt])
		rescue StandardError => e
			puts e.message
			redirect_to root_path
		end
	end

	def create_app
		name = params[:name]
		description = params[:description]

		begin
			app = Dav::App.create(session[:jwt], name, description)
			redirect_to dev_path
		rescue StandardError => e
			puts replace_error_message(e.message)
			flash[:danger] = replace_error_message(e.message)
			redirect_to dev_path
		end
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
			puts replace_error_message(e.message)
			flash[:danger] = replace_error_message(e.message)
			redirect_to show_app_path(params[:id])
		end
	end

	def show_table
		@table = Dav::Table.get(session[:jwt], params[:id], params[:name])
	end

	def show_event
		@event = Dav::Event.get_by_name(session[:jwt], params[:name], params[:id])

		default_period = 60 * 60 * 24 * 30	# Ca. one month
		sort_by = params["sort_by"]
		period = params["period"] ? params["period"] : default_period

		period_start = Time.now - period.to_i

		@sorted_date_logs = Hash.new
		@sorted_data_logs = Hash.new

		@event.logs.each do |log|
			log_date = log["created_at"].to_date

			if log_date > period_start
				log_data = log["data"]

				if sort_by == "year"
					date = "#{log_date.year}"
				elsif sort_by == "month"
					date = "#{log_date.strftime("%B")} #{log_date.year}"
				else
					# Amerikanische Schreibweise: MM.DD.YY
					date = "#{log_date.month}.#{log_date.day}.#{log_date.year}"
				end

				if @sorted_date_logs[date]	# If the date exists, add one to the value of the date
					@sorted_date_logs[date] = @sorted_date_logs[date] + 1
				else
					@sorted_date_logs[date] = 1
				end

				if log_data
					if @sorted_data_logs[log_data] 
						@sorted_data_logs[log_data] = @sorted_data_logs[log_data] + 1
					else
						@sorted_data_logs[log_data] = 1
					end
				end
			end
		end
	end

	def set_event_period
		period_length = params[:period].to_i
		period_format = params[:period_format]
		sort_by = params[:sort_by]

		case period_format
			when "Hours"
				period = period_length * 60 * 60
			when "Days"
				period = period_length * 24 * 60 * 60
			when "Weeks"
				period = period_length * 7 * 24 * 60 * 60
			when "Months"
				period = period_length * 4 * 7 * 24 * 60 * 60
			when "Years"
				period = period_length * 365 * 24 * 60 * 60
			else
				period = period_length * 7 * 24 * 60 * 60
		end

		redirect_to show_event_path(sort_by: sort_by, period: period)
	end
end