class DevsController < ApplicationController

	before_action :require_user

	def index
		begin
			@dev = Dav::Dev.get(session[:jwt])
		rescue StandardError => e
			puts e.message
			flash[:danger] = "There was an error: " + e.message
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

	def general
		begin
			@users = Dav::Analytics.get_users(session[:jwt])["users"]
			@plan_count = Hash.new

			@active_users_count = Hash.new
			@daily_active_users = Dav::Analytics.get_active_users(session[:jwt], 0)["users"]
			@monthly_active_users = Dav::Analytics.get_active_users(session[:jwt], 1)["users"]
			@yearly_active_users = Dav::Analytics.get_active_users(session[:jwt], 2)["users"]

			@active_users_count["Daily"] = @daily_active_users.count
			@active_users_count["Monthly"] = @monthly_active_users.count
			@active_users_count["Yearly"] = @yearly_active_users.count

			@confirmed_users_count = Hash.new
			@confirmed_users_count["Confirmed"] = 0
			@confirmed_users_count["Unconfirmed"] = 0

			@users.each do |user|
				if user["confirmed"]
					@confirmed_users_count["Confirmed"] += 1
				else
					@confirmed_users_count["Unconfirmed"] += 1
				end
			end

			# Sort for the users chart
			default_period = 10 * 365 * 24 * 60 * 60		# 10 years
			sort_by = params["sort_by"]
			period = params["period"] ? params["period"] : default_period

			sorted_arrays = count_time_cumulatively(period, sort_by, @users, "created_at")
			@sorted_array = sorted_arrays[0]

			# Set the plan count
			@plan_count["Free"] = 0
			@plan_count["Plus"] = 0
			@users.each do |user|
				plan = user["plan"]
				if plan == 0
					@plan_count["Free"] += 1
				elsif plan == 1
					@plan_count["Plus"] += 1
				end
			end

			@new_users_count = sorted_arrays[1].count
		rescue StandardError => e
			puts e.message
			flash[:danger] = "There was an error: " + e.message
			redirect_to root_path
		end
	end

	def set_general_period
		period_length = params[:period].to_i
		period_format = params[:period_format]
		sort_by = params[:sort_by]

		period = convert_period_to_timestamp(period_format, period_length)

		redirect_to show_general_path(sort_by: sort_by, period: period)
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
		default_period = 60 * 60 * 24 * 30	# Ca. one month
		sort_by = params["sort_by"].to_s.empty? ? "day" : params["sort_by"]
		period = params["period"] ? params["period"] : default_period
		period_start = Time.now - period.to_i

		@event = Dav::Event.get_by_name(session[:jwt], params[:name], params[:id], sort_by, period_start.strftime("%s"))

		@sorted_date_logs = Hash.new
		@sorted_data_logs = Hash.new
		event_logs = Array.new

		# Remove all logs that are outside the period
		@event.logs.each do |log|
			log_date = DateTime.parse(log.time)

			if log_date > period_start
				event_logs.push(log)
			end
		end

		if event_logs.count == 0
			return
		end

		# Set every entry between the first date and the last date to 0
		start_date = DateTime.parse(event_logs.first.time)
		end_date = DateTime.parse(event_logs.last.time)

		if sort_by == "year"
			RailsDateRange(start_date..end_date).every(years: 1).each do |log|
				@sorted_date_logs[format_year(log)] = 0
			end

			@sorted_date_logs[format_year(start_date)] = 0
			@sorted_date_logs[format_year(end_date)] = 0
		elsif sort_by == "month"
			RailsDateRange(start_date..end_date).every(months: 1).each do |log|
				@sorted_date_logs[format_month(log)] = 0
			end

			@sorted_date_logs[format_month(start_date)] = 0
			@sorted_date_logs[format_month(end_date)] = 0
		elsif sort_by == "hour"
			RailsDateRange(start_date..end_date).every(hours: 1).each do |log|
				@sorted_date_logs[format_hour(log)] = 0
			end

			@sorted_date_logs[format_hour(start_date)] = 0
			@sorted_date_logs[format_hour(end_date)] = 0
		else	# Sort by day
			RailsDateRange(start_date..end_date).every(days: 1).each do |log|
				@sorted_date_logs[format_day(log)] = 0
			end

			@sorted_date_logs[format_day(start_date)] = 0
			@sorted_date_logs[format_day(end_date)] = 0
		end

		@countries = Hash.new
		@browser_with_version = Hash.new
		@browser_without_version = Hash.new
		@os_with_version = Hash.new
		@os_without_version = Hash.new
		@chrome_versions = Hash.new
		@firefox_versions = Hash.new
		@edge_versions = Hash.new
		@windows_versions = Hash.new
		@android_versions = Hash.new

		event_logs.each do |log|
			# Get the date
			log_date = DateTime.parse(log.time)

			if sort_by == "year"
				date = format_year(log_date)
			elsif sort_by == "month"
				date = format_month(log_date)
			elsif sort_by == "hour"
				date = format_hour(log_date)
			else	# Sort_by == day
				date = format_day(log_date)
			end

			@sorted_date_logs[date] = @sorted_date_logs[date] + log.total

			# Get the country
			country = get_property_counts_by_name(log.properties, "country").first
			if country
				@countries[country] ? @countries[country] = @countries[country] + 1 : @countries[country] = 1
			end

			# Get the browser
			browser_names = get_property_counts_by_name(log.properties, "browser_name")
			browser_versions = get_property_counts_by_name(log.properties, "browser_version")
			
			i = 0
			browser_names.each do |browser_name_hash|
				browser_name = browser_name_hash["value"]
				browser_version = browser_versions[i]["value"]
				name = "#{browser_name} #{browser_version}"
				count = browser_names[i]["count"]

				# Increase the count of the browser in @browser_without_version
				@browser_without_version[browser_name] ? @browser_without_version[browser_name] += count : @browser_without_version[browser_name] = count

				# Increase the count of the browser in @browser_with_version
				@browser_with_version[name] ? @browser_with_version[name] += count : @browser_with_version[name] = count

				# Increase the count of the specific browser
				if browser_name.include? "Chrome"
					# @chrome_versions
					@chrome_versions[name] ? @chrome_versions[name] += count : @chrome_versions[name] = count
				elsif browser_name.include? "Firefox"
					# @firefox_versions
					@firefox_versions[name] ? @firefox_versions[name] += count : @firefox_versions[name] = count
				elsif browser_name.include? "Edge"
					# @edge_versions
					@edge_versions[name] ? @edge_versions[name] = @edge_versions[name] += count : @edge_versions[name] = count
				end

				i += 1
			end

			# Get the os
			i = 0
			log.properties.each do |property|
				if property["name"] == "os_name"
					# Increase the count of the os in @os_without_version
					count = property["count"]
					name = property["value"]
					@os_without_version[name] ? @os_without_version[name] += count : @os_without_version[name] = count

					if log.properties[i + 1] && log.properties[i + 1]["name"] == "os_version"
						# Increase the count of the os in @os_with_version
						name = "#{property["value"]} #{log.properties[i + 1]["value"]}"
						@os_with_version[name] ? @os_with_version[name] += count : @os_with_version[name] = count

						# Increase the count of the specific os
						if name.include? "Windows"
							# @windows_versions
							@windows_versions[name] ? @windows_versions[name] += count : @windows_versions[name] = count
						elsif name.include? "Android"
							# @android_versions
							@android_versions[name] ? @android_versions[name] += count : @android_versions[name] = count
						end
					end
				end

				i += 1
			end
		end
	end

	def set_event_period
		period_length = params[:period].to_i
		period_format = params[:period_format]
		sort_by = params[:sort_by]

		period = convert_period_to_timestamp(period_format, period_length)

		redirect_to show_event_path(sort_by: sort_by, period: period)
	end

	def general_app
		begin
			@app = Dav::App.get(session[:jwt], params[:id])
			@analytics = Dav::Analytics.get_app(session[:jwt], params[:id])

			# Sort for the users chart
			default_period = 10 * 365 * 24 * 60 * 60		# 10 years
			sort_by = params["sort_by"]
			period = params["period"] ? params["period"] : default_period

			sorted_arrays = count_time_cumulatively(period, sort_by, @analytics["users"], "started_using")

			@sorted_time = sorted_arrays[0]
			@new_users_count = sorted_arrays[1].count
			@total_users_count = @analytics["users"].count
		rescue => e
			puts e.message
			flash[:danger] = "There was an error: " + e.message
			redirect_to root_path
		end
	end

	def set_general_app_period
		period_length = params[:period].to_i
		period_format = params[:period_format]
		sort_by = params[:sort_by]
		id = params[:id]

		period = convert_period_to_timestamp(period_format, period_length)

		redirect_to show_general_app_path(id: id, sort_by: sort_by, period: period)
	end

	private
	def convert_period_to_timestamp(period_format, period_length)
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

		return period
	end

	def count_time_cumulatively(period, sort_by, source_array, time_field_name)
		period_start = Time.now - period.to_i

		sorted_time = Hash.new
		users_period = Array.new

		# Remove all logs that are outside the period
		source_array.each do |user|
			if user[time_field_name]
				user_date = DateTime.parse(user[time_field_name])

				if user_date > period_start
					users_period.push(user)
				end
			end
		end

		if users_period.count == 0
			return [sorted_time, users_period]
		end

		if !source_array.first[time_field_name]
			first_date = DateTime.parse(source_array.second[time_field_name])
		else
			first_date = DateTime.parse(source_array.first[time_field_name])
		end
		start_date = DateTime.parse(users_period.first[time_field_name])
		end_date = DateTime.now

		if sort_by == "year"
			sorted_time[format_year(start_date)] = 0

			RailsDateRange(start_date..end_date + 1.years).every(years: 1).each do |date|
				sorted_time[format_year(date)] = 0

				source_array.each do |user|
					if (first_date..date).cover?(user[time_field_name])
						sorted_time[format_year(date)] += 1
					end
				end
			end
		elsif sort_by == "day"
			sorted_time[format_day(start_date)] = 0

			RailsDateRange(start_date..end_date + 1.day).every(days: 1).each do |date|
				sorted_time[format_day(date)] = 0

				source_array.each do |user|
					if (first_date..date).cover?(user[time_field_name])
						sorted_time[format_day(date)] += 1
					end
				end
			end
		elsif sort_by == "hour"
			sorted_time[format_hour(start_date)] = 0

			RailsDateRange(start_date..end_date + 1.hour).every(hours: 1).each do |date|
				sorted_time[format_hour(date)] = 0

				source_array.each do |user|
					if (first_date..date).cover?(user[time_field_name])
						sorted_time[format_hour(date)] += 1
					end
				end
			end
		else	# Sort by month
			sorted_time[format_month(start_date)] = 0

			RailsDateRange(start_date..end_date + 1.months).every(months: 1).each do |date|
				sorted_time[format_month(date)] = 0

				source_array.each do |user|
					if (first_date..date).cover?(user[time_field_name])
						sorted_time[format_month(date)] += 1
					end
				end
			end
		end
		
		return [sorted_time, users_period]
	end

	def get_property_counts_by_name(property_count_array, property_name)
		value_array = property_count_array.select { |p| p["name"] == property_name }
		
		if value_array && value_array.count > 0
			return value_array
		else
			return Array.new
		end
	end
end