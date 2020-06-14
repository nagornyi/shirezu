class Confirmation < ActiveRecord::Base
has_one :user

	attr_accessible :email, :code, :company_id, :project_id, :role_id
end

