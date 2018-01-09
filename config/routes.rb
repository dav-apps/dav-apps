Rails.application.routes.draw do
  	root 'starts#index'

	# UsersController
	get 'login', to: 'users#login'
	post 'login', to: 'users#login_action'
	get 'logout', to: 'users#logout'
	get 'signup', to: 'users#signup'
	post 'signup', to: 'users#signup_action'
	get 'password_reset', to: 'users#password_reset'
	post 'password_reset', to: 'users#password_reset_action'
	get 'reset_password/:password_confirmation_token', to: 'users#reset_password', as: 'reset_password'
	post 'reset_password/:password_confirmation_token', to: 'users#reset_password_action'
	get 'resend_activation_email', to: 'users#resend_activation_email'
	post 'resend_activation_email', to: 'users#resend_activation_email_action'

	# AppsController
	get 'apps', to: 'apps#index'
end
