class ProjectsController < ApplicationController
	before_filter :authenticate_user!
	authorize_resource :project
	respond_to :html,:json

	protect_from_forgery :except => [:post_data]

  def post_data
    message=""
    resource_params = { :id => params[:id], :name => params[:name], :description => params[:description] }

    case params[:oper]
    when 'add'
			params[:id] = "_empty"
			project = Project.create(resource_params)
			project.update_attribute(:company_id, current_user.company_id)

      if project.errors.empty?
				message << ('ok')
			else
				message << ("Unable to create a project.")
			end

    when 'edit'
			project = Project.find(params[:id])
			message << ('ok') if project.update_attributes(resource_params)

    when 'del'
	  User.destroy_all(:project_id => params[:id])
	  Resource.destroy_all(:project_id => params[:id])
      Project.destroy_all(:id => params[:id].split(","))
      message <<  ('ok')

    when 'sort'
      projects = Project.all
      projects.each do |project|
        project.position = params['ids'].index(project.id.to_s) + 1 if params['ids'].index(project.id.to_s) 
        project.save
      end
      message << "ok"
      
	when 'invite'
		project = Project.find(params[:id])
		company = Company.where(:id => project.read_attribute(:company_id)).first
		invite_code = Random.new.rand(1_000_000..10_000_000-1).to_s
		confirmation = Confirmation.create({ :email => params[:email], :code => invite_code, :company_id => company.id, :project_id => project.id, :role_id => 3 })
		t = Thread::new {
			ShrezMailer.common_mail(params[:email], "Shirezu: invitation to \""+project.name.to_s+"\" project, \""+company.name.to_s+"\" company from Company Administrator", "Hello, new user! Welcome to Shirezu.com. You've been invited as Project Administrator. Please register at www.shirezu.com/users/sign_up entering the following invite code (without spaces): " + invite_code).deliver		
		}
		t.run
		message << "ok"

	when 'invite_operator'
		project = Project.find(params[:id])
		company = Company.where(:id => project.read_attribute(:company_id)).first
		invite_code = Random.new.rand(1_000_000..10_000_000-1).to_s
		confirmation = Confirmation.create({ :email => params[:email], :code => invite_code, :company_id => company.id, :project_id => project.id, :role_id => 4 })
		t = Thread::new {
			ShrezMailer.common_mail(params[:email], "Shirezu: invitation to \""+project.name.to_s+"\" project, \""+company.name.to_s+"\" company from Company Administrator", "Hello, new user! Welcome to Shirezu.com. You've been invited as Operator. Please register at www.shirezu.com/users/sign_up entering the following invite code (without spaces): " + invite_code).deliver		
		}
		t.run
		message << "ok"

    else
      message <<  ('unknown action')
    end
    unless (project && project.errors).blank?
      render :json => [false,message]
    else
      render :json => [true,message]
    end
  end

  def index
    params[:_search] = "true"
	params[:company_id]=current_user.company_id if @current_user.role? :company_administrator
  
    index_columns ||= [:id,:name,:description,:company_id]
    current_page = params[:page] ? params[:page].to_i : 1
    rows_per_page = params[:rows] ? params[:rows].to_i : 10

    conditions={:page => current_page, :per_page => rows_per_page}
    conditions[:order] = params["sidx"] + " " + params["sord"] unless (params[:sidx].blank? || params[:sord].blank?)
    
    if params[:_search] == "true"
      conditions[:conditions]=filter_by_conditions(index_columns)
    end

    @projects=Project.paginate(conditions)

    total_entries=@projects.total_entries

	parsed_json = ActiveSupport::JSON.decode(@projects.to_jqgrid_json(index_columns, current_page, rows_per_page, total_entries))

	begin
	parsed_json["rows"].each do |row|
		row.each_pair do |key,value|
			if key=='cell'		
				if value[3]!=''
					ini_val = value[3]
					value[3] = Company.find(value[3].to_s).read_attribute(:name).to_s + " <small>(search id: #{ini_val})</small>"
				end
			end
		end
	end
	rescue
	end

    respond_with(@projects) do |format|
		format.json { render :json => ActiveSupport::JSON.encode(parsed_json)}
    end
  end
  
end
