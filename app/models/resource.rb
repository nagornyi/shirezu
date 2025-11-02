class Resource < ActiveRecord::Base
	validates_presence_of :name, :message => "is blank, you should enter some name here", :on => :save
	validates_uniqueness_of :name, :message => "already exists in the database"  
	#validates_presence_of :user_id
	validates_length_of :name, :maximum => 25, :message => 'is too long, should be no more than 25 symbols'
	validates_length_of :description, :maximum => 25, :message => 'is too long, should be no more than 25 symbols'
	attr_accessible :description, :name, :user_id, :occupied_at, :notification, :flags, :project_id, :company_id

  def self.return_resources
    find(:all, :order=>"name, description")
  end

end
