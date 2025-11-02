class Company < ActiveRecord::Base
	has_one :project
	has_one :user

	attr_accessible :name, :description
end

