source 'https://rubygems.org'

git_source(:github) do |repo_name|
  	repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  	"https://github.com/#{repo_name}.git"
end

ruby '2.4.1'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Bootstrap and Jquery
gem 'bootstrap', '~> 4.1.0'
gem 'jquery-rails'
gem 'sprockets'

# Font Awesome
gem "font-awesome-rails"

# dav gem
gem 'dav', github: 'Dav2070/dav-gem'

# Session store for storing sessions in DB
gem 'activerecord-session_store'

# Displaying charts
gem "chartkick"

# IP location
gem 'ipinfo_io', github: "ipinfo/ruby"

group :development, :test do
	# Call 'byebug' anywhere in the code to stop execution and get a debugger console
	gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
	# Adds support for Capybara system testing and selenium driver
	gem 'capybara', '~> 2.13'
	gem 'selenium-webdriver'

	# Use sqlite3 as the database for Active Record
	gem 'sqlite3'

	# Environment variables
	gem 'dotenv-rails'
end

group :development do
	# Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
	gem 'web-console', '>= 3.3.0'
	gem 'listen', '>= 3.0.5', '< 3.2'
	# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
	gem 'spring'
	gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
	# Postgres for the production db
	gem 'pg', '~> 0.21.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
