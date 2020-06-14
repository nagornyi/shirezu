class Profile < ActiveRecord::Base
	has_one :user

	# Setup accessible (or protected) attributes for your model
	attr_accessible :time_zone
end

