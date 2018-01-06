Rails.application.routes.draw do
  	root 'starts#index'

	# UsersController
	get 'login', to: 'users#login'
end
