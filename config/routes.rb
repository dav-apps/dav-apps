Rails.application.routes.draw do

	# StartsController
	root 'starts#index'
	get 'privacy', to: 'starts#privacy'
	get 'contact', to: 'starts#contact'
	get 'pricing', to: 'starts#pricing'

	# UsersController
	get 'login', to: 'users#login'
	post 'login', to: 'users#login_action'
	get 'login_implicit', to: 'users#login_implicit'
	post 'login_implicit', to: 'users#login_implicit_action'
	get 'logout', to: 'users#logout'
	get 'signup', to: 'users#signup'
	post 'signup', to: 'users#signup_action'
	get 'user', to: 'users#show'
	post 'user', to: 'users#update'
	get 'redirect', to: 'users#redirect'

	get 'password_reset', to: 'users#password_reset'
	post 'password_reset', to: 'users#password_reset_action'
	get 'reset_password/:password_confirmation_token', to: 'users#reset_password', as: 'reset_password'
	post 'reset_password/:password_confirmation_token', to: 'users#reset_password_action'
	get 'confirm_user/:id/:email_confirmation_token', to: 'users#confirm_user', as: 'confirm_user'
	post 'confirm_user/:id/:email_confirmation_token', to: 'users#confirm_user_action'
	get 'change_email/:id/:email_confirmation_token', to: 'users#change_email'
	get 'change_password/:id/:password_confirmation_token', to: 'users#change_password'
	get 'reset_new_email/:id', to: 'users#reset_new_email'
	get 'delete_account/:id/:email_confirmation_token/:password_confirmation_token', to: 'users#delete_account'

	# AppsController
	get 'apps', to: 'apps#index'

	# DevsController
	get 'dev', to: 'devs#index'
	post 'dev', to: 'devs#create_app'
	get 'dev/general', to: 'devs#general', as: 'show_general'
	post 'dev/general', to: 'devs#set_general_period'
	get 'dev/:id', to: 'devs#show', as: 'show_app'
	post 'dev/:id', to: 'devs#create_table'
	get 'dev/:id/table/:name', to: 'devs#show_table', as: 'show_table'
	get 'dev/:id/event/:name', to: 'devs#show_event', as: 'show_event'
	post 'dev/:id/event/:name', to: 'devs#set_event_period'
	get 'dev/:id/general', to: 'devs#general_app', as: 'show_general_app'
	post 'dev/:id/general', to: 'devs#set_general_app_period'
end
