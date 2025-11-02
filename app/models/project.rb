class Project < ActiveRecord::Base
	has_one :user
	
	belongs_to :company
	has_one :companies

	attr_accessible :name, :description, :company_id
end
