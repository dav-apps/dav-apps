Rails.application.routes.draw do
  	root 'starts#index'

	# UsersController
	get 'login', to: 'users#login'
	post 'login', to: 'users#login_action'
	get 'logout', to: 'users#logout'
	get 'signup', to: 'users#signup'
	post 'signup', to: 'users#signup_action'

	# AppsController
	get 'apps', to: 'apps#index'
end
