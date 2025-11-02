class ApplicationController < ActionController::Base
	#helper :all # include all helpers, all the time
  protect_from_forgery
	#def redirect_to(options = {}, response_status = {})
	#	if request.xhr?
	#	  render(:update) {|page| page.redirect_to(options)}
	#	else
	#	  super(options, response_status)
	#	end
	#end
def after_sign_in_path_for(resource_or_scope)
    "/resources"
end

def after_sign_out_path_for(resource_or_scope)
    "/users/sign_in"
end
end

