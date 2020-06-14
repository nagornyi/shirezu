class ResourcesController < ApplicationController
	before_filter :authenticate_user!
	authorize_resource :resource
	respond_to :html,:json

	protect_from_forgery :except => [:post_data]

  def post_data
    message=""
    resource_params = { :id => params[:id],:flags => params[:flags],:name => params[:name],:description => params[:description],:user_id => params[:user_id],:occupied_at => params[:occupied_at] }

    case params[:oper]
		
    	when 'get_projects_list'
			tz = "<select style=\"width:100px\" id=\"resPrj\" name=\"resPrj\">"
			tz = tz + "<option value=\"\"><\/option>"
			if @current_user.role? :administrator
				message << ("true")
			elsif Project.find(:all, :conditions => { :company_id => @current_user.company_id}).blank?
				message << ("false")
			else
				Project.find(:all, :conditions => { :company_id => @current_user.company_id}).each do |res|	
					tz = tz + "<option value=\"#{res.name}\">#{res.name}<\/option>"
				end
				tz = tz + "<\/select>"
				message << (tz)
			end
    
		when 'notify'
			resource = Resource.find(params[:id])
			notifications_str = resource.read_attribute(:notification)
			myemail = current_user.email
			fl_newemail = false
			if notifications_str == nil
				resource_params[:notification] = myemail
				fl_newemail = true
			else
				delim = ','
				notifications_arr = notifications_str.split(delim).map(&:to_s)
				if not notifications_arr.include?(myemail)
					notifications_arr << myemail
					resource_params[:notification] = notifications_arr.join(delim)
					fl_newemail = true
				end
			end
			if fl_newemail == true
				message << ('ok') if resource.update_attribute(:notification, resource_params[:notification]) and resource.update_attribute(:flags, 'ON')
			else
				message << ('ok')
			end

		when 'email'
			resource = Resource.find(params[:id])
			user = User.find(resource.read_attribute(:user_id))
			t = Thread::new {
				ShrezMailer.common_mail(user.read_attribute(:email), "Shirezu: question concerning a \""+resource.read_attribute(:name)+"\" resource from user "+user.read_attribute(:username), params[:message]).deliver		
			}
			t.run
			message << ('ok')

    when 'add'
			params[:id] = "_empty"
			if resource_params[:user_id] == ''
				resource_params[:user_id] = current_user.id 
				resource_params[:occupied_at] = Time.now	
				resource_params[:flags] = 'O'
			else
				resource_params[:user_id] = nil
				resource_params[:occupied_at] = nil		
				resource_params[:flags] = 'F'
			end			
			if params[:project] == nil
			resource_params[:project_id] = current_user.project_id
			else
			prj = Project.where(:name => params[:project]).first
			resource_params[:project_id] = prj.id
			end
			resource_params[:company_id] = current_user.company_id      
			resource = Resource.create(resource_params)
			message << ('ok') if resource.errors.empty?

    when 'edit'
			resource = Resource.find(params[:id])
			if @current_user.role? :administrator or @current_user.role? :company_administrator	or @current_user.role? :global_administrator
				message << ('ok') if resource.update_attribute(:name, resource_params[:name]) and resource.update_attribute(:description, resource_params[:description])
			else
				message << ("You have to be Administrator to change this resource.")
			end

    when 'del'
      Resource.destroy_all(:id => params[:id].split(","))
      message <<  ('ok')

    when 'sort'
      resources = Resource.all
      resources.each do |resource|
        resource.position = params['ids'].index(resource.id.to_s) + 1 if params['ids'].index(resource.id.to_s) 
        resource.save
      end
      message << "ok"

		when 'occupy'
			resource = Resource.find(params[:id])
			status = resource.read_attribute(:user_id)
			if status == nil
				message << ('ok') if resource.update_attribute(:occupied_at, Time.now.utc) and resource.update_attribute(:flags, 'O') and resource.update_attribute(:user_id, current_user.id)
			else
				message << ("Cannot occupy. Resource \"#{resource.read_attribute(:name)}\" has been already occupied by user #{User.find(resource.read_attribute(:user_id)).read_attribute(:username)}. It must be released first.")
			end

		when 'release'
			resource = Resource.find(params[:id])
			status = resource.read_attribute(:user_id)
			project = Project.find(resource.read_attribute(:project_id))
			if status == current_user.id or @current_user.role? :global_administrator or (@current_user.role? :company_administrator and project.read_attribute(:company_id) == current_user.company_id) or (@current_user.role? :administrator and resource.read_attribute(:project_id) == current_user.project_id)
				message << ('ok') if resource.update_attribute(:occupied_at, '') and resource.update_attribute(:flags, 'F') and resource.update_attribute(:user_id, nil)
				notifications_str = resource.read_attribute(:notification)
				if notifications_str != nil
					fresname = resource.read_attribute(:name)
					delim = ','
					notifications_arr = notifications_str.split(delim)
					t = Thread::new {
						notifications_arr.each do |email|
							ShrezMailer.notification_mail(email, fresname).deliver			
						end
					}
					t.run
					resource.update_attribute(:notification, nil)
				end
			elsif status == nil
				message << ('ok')
			else
				message << ("Cannot release. Resource \"#{resource.read_attribute(:name)}\" has been occupied by user #{User.find(resource.read_attribute(:user_id)).read_attribute(:username)}.")
			end

    else
      message <<  ('unknown action')
    end
    unless (resource && resource.errors).blank?
      render :json => [false,message]
    else
      render :json => [true,message]
    end
  end

  def index
	params[:_search] = "true"
	params[:company_id]=current_user.company_id if @current_user.role? :company_administrator or @current_user.role? :administrator or @current_user.role? :operator
	params[:project_id]=current_user.project_id if @current_user.role? :administrator or @current_user.role? :operator
	if (params[:user_id] != nil)
		user = User.where(:username => params[:user_id]).first
		if (user != nil)
			params[:user_id] = user.read_attribute(:id)
		else
			params[:user_id] = 'undefined'
		end
	end
    index_columns ||= [:id,:flags,:name,:description,:user_id,:occupied_at,:notification,:project_id,:company_id]
    current_page = params[:page] ? params[:page].to_i : 1
    rows_per_page = params[:rows] ? params[:rows].to_i : 10

    conditions={:page => current_page, :per_page => rows_per_page}
    conditions[:order] = params["sidx"] + " " + params["sord"] unless (params[:sidx].blank? || params[:sord].blank?)
    
    if params[:_search] == "true"
      conditions[:conditions]=filter_by_conditions(index_columns)
    end

    @resources=Resource.paginate(conditions)

    total_entries=@resources.total_entries

	parsed_json = ActiveSupport::JSON.decode(@resources.to_jqgrid_json(index_columns, current_page, rows_per_page, total_entries))

	begin
	parsed_json["rows"].each do |row|
		row.each_pair do |key,value|
			if key=='cell'		
				if value[4]!=''
					value[4] = User.find(value[4].to_s).read_attribute(:username).to_s
				end
				if value[5]!=''
					tz = TZInfo::Timezone.get(Profile.find(@current_user.profile_id).read_attribute(:time_zone))
					value[5] = tz.utc_to_local(Time.parse(value[5])).strftime("%a, %e %b %Y %H:%M:%S")
				end	
				if value[7]!=''
					ini_val_prj = value[7]
					value[7] = Project.find(value[7].to_s).read_attribute(:name).to_s + " <small>(search id: #{ini_val_prj})</small>"
				end
				if value[8]!=''
					ini_val_comp = value[8]
					value[8] = Company.find(value[8].to_s).read_attribute(:name).to_s + " <small>(search id: #{ini_val_comp})</small>"
				end
			end
		end
	end
	rescue
	end
	
	if can? :manage, Resource
	    respond_with(@resources) do |format|
			format.json { render :json => ActiveSupport::JSON.encode(parsed_json)}
	    end
	end
  end
  
end
