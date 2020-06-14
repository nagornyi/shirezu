class User < ActiveRecord::Base
	before_create :set_role
	has_and_belongs_to_many :roles
	belongs_to :profile
	has_one :profiles
	belongs_to :company
	has_one :companies
	belongs_to :project
	has_one :projects
	belongs_to :confirmation
	has_one :confirmations
	accepts_nested_attributes_for :profiles
	accepts_nested_attributes_for :confirmations
	# Include default devise modules. Others available are:
	# :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
	devise :registerable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
	validates_uniqueness_of :username, :message => "already exists in the database."  
  validates_exclusion_of :username, :in => ['Username'], :message => "needs to be entered."
	validates_exclusion_of :password, :in => ['Password'], :message => "needs to be entered."
	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :username, :profile_id, :password_confirmation, :remember_me, :role_ids, :code, :company_id, :project_id
	
	@@email = nil
	begin
	if !User.find(:all).blank?
		validates_each :email, :on => :create do |record, attr, value|
			@@email = value
		end
		validates_each :code, :on => :create do |record, attr, value|
		if value!="trial"      
			confirmation = Confirmation.where(:email => @@email).first      
      confirmation_code = confirmation.read_attribute(:code) if confirmation
			record.errors.add attr, " is incorrect. Please enter correct invite code." unless confirmation_code && value && value == confirmation.read_attribute(:code)
      
      t = Thread::new {
				ShrezMailer.common_mail(@@email, "Shirezu: welcome new user!", "Congratulations, you have successfully registered in Shirezu. Thank you for using our software.\n\n----------\nBest regards,\nAdministration of project www.shirezu.com").deliver		
			}
			t.run
		else
      company = Company.create({ :name => "My Company", :description => "trial" })      
      Confirmation.create({ :email => @@email, :code => "trial", :company_id => company.read_attribute(:id), :role_id => 2 })
            
      t = Thread::new {
				ShrezMailer.common_mail(@@email, "Shirezu: welcome new user!", "Congratulations, you have successfully registered in Shirezu. Enjoy your free 14-day fully-functional trial now! Thank you for using our software.\n\n----------\nBest regards,\nAdministration of project www.shirezu.com").deliver		
			}
			t.run
		end		
		end
	end
	rescue
	end

	def role?(role)
		return !!self.roles.find_by_name(role.to_s.camelize)
	end
	
	private
	def set_role
		begin
		if !User.find(:all).blank?
			if confirmation = Confirmation.where(:email => @@email).first
			role = Role.find(confirmation.read_attribute(:role_id))
			else
			role = Role.find(2)
			end
			self.roles << role
		else
			role = Role.find(1)
			self.roles << role
		end
		rescue
		end
	end
end
