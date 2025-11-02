Shrez::Application.routes.draw do
	resources :roles
	
	#devise_for :users

	devise_for :users, :controllers => {:registrations => "ext_registrations"}
	devise_for :resources
	resources :users
	resources :resources

	root :to => 'resources#index'

	match '/token' => 'home#token', :as => :token

	resources :resources,:only => [:index] do
	 collection do
	   post 'post_data'
	 end
	end

	match '/:controller(/:action(/:id))'
	#match ':controller(/:action(/:id(.:format)))'
	match '/:controller(/:action)'
	match '/:controller/:id/:action'
end
