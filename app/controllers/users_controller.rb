class UsersController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource
	respond_to :html,:json

	protect_from_forgery :except => [:post_data]

  def post_data
    message=""
    resource_params = { :id => params[:id],:username => params[:username],:time_zone => params[:time_zone],:profile_id => params[:profile_id] }
    case params[:oper]

    when 'add'

    when 'edit'

    when 'del'
		resource = Resource.find(:user_id => params[:id]) if !Resource.find(:all).blank?
		if resource != nil
			resource.update_attribute(:occupied_at, '')
			resource.update_attribute(:flags, 'F')
			resource.update_attribute(:user_id, nil)
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
		end
		profile = Profile.find(User.find(params[:id]).read_attribute(:profile_id))
		profile.destroy
		User.destroy_all(:id => params[:id].split(","))
		message <<  ('ok')

    when 'sort'
      users = User.all
      users.each do |user|
        user.position = params['ids'].index(user.id.to_s) + 1 if params['ids'].index(user.id.to_s) 
        user.save
      end
      message << "ok"

	when 'invite'
		project = Project.find(current_user.project_id)
		company = Company.find(current_user.company_id)
		invite_code = Random.new.rand(1_000_000..10_000_000-1).to_s
		confirmation = Confirmation.create({ :email => params[:email], :code => invite_code, :company_id => current_user.company_id, :project_id => current_user.project_id, :role_id => 4 })
		t = Thread::new {
			ShrezMailer.common_mail(params[:email], "Shirezu: invitation to \""+project.name.to_s+"\" project, \""+company.name.to_s+"\" company from Project Administrator", "Hello, new user! Welcome to Shirezu.com. You've been invited as Operator. Please register at www.shirezu.com/users/sign_up entering the following invite code (without spaces): " + invite_code).deliver		
		}
		t.run
		message << "ok"

    else
      message <<  ('unknown action')
    end
    unless (user && user.errors).blank?  
      user.errors.entries.each do |error|
        message << "<strong>#{User.human_attribute_name(error[0])}</strong> : #{error[1]}<br/>"
      end
      render :json =>[false,message]
    else
      render :json => [true,message] 
    end
  end

  def index
  	params[:_search] = "true"
  	if params[:project_id] != nil
		project_search_str = params[:project_id] 
		params.delete(:project_id)
	end
	if params[:company_id] != nil
		company_search_str = params[:company_id] 
		params.delete(:company_id)
	end
	
    index_columns ||= [:id,:username,:profile_id,:project_id,:company_id,:role]

    current_page = params[:page] ? params[:page].to_i : 1
    rows_per_page = params[:rows] ? params[:rows].to_i : 10

    conditions={:page => current_page, :per_page => rows_per_page}
    conditions[:order] = params["sidx"] + " " + params["sord"] unless (params[:sidx].blank? || params[:sord].blank?)
    
    conditions[:conditions]=filter_by_conditions(index_columns)
    
    if conditions[:conditions] != ""
		conditions[:conditions] += " and company_id LIKE #{current_user.company_id}" if @current_user.role? :company_administrator or @current_user.role? :administrator
    else
		conditions[:conditions] += "company_id LIKE #{current_user.company_id}" if @current_user.role? :company_administrator or @current_user.role? :administrator
    end
    if conditions[:conditions] != ""
		conditions[:conditions] += " and project_id LIKE #{current_user.project_id}" if @current_user.role? :administrator
    else
		conditions[:conditions] += "project_id LIKE #{current_user.project_id}" if @current_user.role? :administrator
    end
    
    if params[:time_zone] != nil
		selected_profiles = Profile.find(:all, :conditions => ['time_zone LIKE ? ', ''+params[:time_zone].to_s+'%'])
		conditions[:conditions] += ' and ' unless conditions[:conditions] == ""
		conditions[:conditions] += '('
	    selected_profiles.each do |prof|
			conditions[:conditions] += 'profile_id like "' + prof.id.to_s + '" or '
	    end
	    conditions[:conditions] = conditions[:conditions][0..-5]
	    conditions[:conditions] += ')'
    end
    
    if project_search_str != nil
		selected_projects = Project.find(:all, :conditions => ['name LIKE ? ', '%'+project_search_str+'%'])
		conditions[:conditions] += ' and ' unless conditions[:conditions] == ""
		conditions[:conditions] += '('
	    selected_projects.each do |proj|
			conditions[:conditions] += 'project_id like "' + proj.id.to_s + '" or '
	    end
	    conditions[:conditions] = conditions[:conditions][0..-5]
	    conditions[:conditions] += ')'
  	end
  	
	if company_search_str != nil
		selected_companies = Company.find(:all, :conditions => ['name LIKE ? ', '%'+company_search_str+'%'])
		conditions[:conditions] += ' and ' unless conditions[:conditions] == ""
		conditions[:conditions] += '('
	    selected_companies.each do |comp|
			conditions[:conditions] += 'company_id like "' + comp.id.to_s + '" or '
	    end
	    conditions[:conditions] = conditions[:conditions][0..-5]
	    conditions[:conditions] += ')'
  	end
    
    @users=User.paginate(conditions)
    total_entries=@users.total_entries
    
	parsed_json = ActiveSupport::JSON.decode(@users.to_jqgrid_json(index_columns, current_page, rows_per_page, total_entries))

	begin
		parsed_json["rows"].each do |row|
			row.each_pair do |key,value|
				if key=='cell'
					value[2] = Profile.find(value[2]).read_attribute(:time_zone)
					if value[3]!=''
						ini_val_prj = value[3]
						value[3] = Project.find(value[3].to_s).read_attribute(:name).to_s + " <small>(search id: #{ini_val_prj})</small>"
					end
					if value[4]!=''
						ini_val_comp = value[4]
						value[4] = Company.find(value[4].to_s).read_attribute(:name).to_s + " <small>(search id: #{ini_val_comp})</small>"
					end
					value[5] = "Operator" if User.find(value[0].to_s).role? :operator
					value[5] = "<font color='red'>Administrator</font>" if User.find(value[0].to_s).role? :administrator
					value[5] = "<font color='red'>Company Administrator</font>" if User.find(value[0].to_s).role? :company_administrator
					value[5] = "<font color='red'>Global Administrator</font>" if User.find(value[0].to_s).role? :global_administrator
					value[1] = "<b>#{value[1]}</b> <small>(this is You)</small>" if value[1].to_s == current_user.username
				end
			end
		end
	rescue
	end

    respond_with(@users) do |format|
		format.json { render :json => ActiveSupport::JSON.encode(parsed_json)}
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    @current_method = "new"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
	profile = Profile.create(params[:user][:profile])
	user = User.find(@user.read_attribute(:id))
	user.update_attribute(:profile_id, profile.read_attribute(:id))

    respond_to do |format|
      if @user.save
		    format.html { redirect_to(users_url) }
		    format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])
		@profile = Profile.find(@user.read_attribute(:profile_id))

    respond_to do |format|
			if params[:user][:password] == 'Password'
				params[:user][:password] = @user.read_attribute(:password)
			end

			if @user.update_attributes(params[:user]) && @profile.update_attribute(:time_zone, params[:user][:profile][:time_zone])
				format.html { redirect_to(users_url) }
				format.xml  { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
			end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

end
