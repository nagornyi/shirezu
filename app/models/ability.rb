class Ability
  include CanCan::Ability
 
  def initialize(user)
	user ||= User.new # guest user

    if user.role? :global_administrator
		can :manage, :all
    elsif user.role? :company_administrator
    can :manage, Resource, :company_id => user.company_id.to_s
		can :manage, User, :company_id => user.company_id		
		can :manage, Project, :company_id => user.company_id
    can :manage, Company, :id => user.company_id
		can :manage, Profile
		can :manage, Helper
    elsif user.role? :administrator
		can :manage, Resource, :project_id => user.project_id
		can :manage, User, :project_id => user.project_id
		can :manage, Profile
		can :manage, Helper
    elsif user.role? :operator
		can :manage, Resource, :project_id => user.project_id
		can :manage, Profile
		can :manage, Helper
    else    
		#can :read, :all
		#can :read, Resource
		#can :read, User
		#can :read, Profile
		#can :read, Project
		#can :read, Company
    end
  end
end
