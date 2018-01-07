Rails.application.routes.draw do
  	root 'starts#index'

	# UsersController
	get 'login', to: 'users#login'
	post 'login', to: 'users#login_action'
	delete 'logout', to: 'users#logout'
	get 'signup', to: 'users#signup'
	post 'signup', to: 'users#signup_action'
end
