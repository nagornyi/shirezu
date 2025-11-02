class CompaniesController < ApplicationController
	before_filter :authenticate_user!
	authorize_resource :company
	respond_to :html,:json

	protect_from_forgery :except => [:post_data]

  def post_data
	message=""
	resource_params = { :id => params[:id], :name => params[:name], :description => params[:description] }

    case params[:oper]
    when 'add'
		params[:id] = "_empty"
		company = Company.create(resource_params)

		if company.errors.empty?
		message << ('ok')
		else
		message << ("Unable to create a company.")
		end

    when 'edit'
		company = Company.find(params[:id])
		message << ('ok') if company.update_attributes(resource_params)

    when 'del'
		User.destroy_all(:company_id => params[:id])
		Resource.destroy_all(:company_id => params[:id])
		Project.destroy_all(:company_id => params[:id])
		Company.destroy_all(:id => params[:id].split(","))
		message <<  ('ok')

    when 'sort'
		companies = Company.all
		companies.each do |company|
			company.position = params['ids'].index(company.id.to_s) + 1 if params['ids'].index(company.id.to_s) 
			company.save
		end
		message << "ok"
		
	when 'invite'
		company = Company.find(params[:id])
		invite_code = Random.new.rand(1_000_000..10_000_000-1).to_s
		confirmation = Confirmation.create({ :email => params[:email], :code => invite_code, :company_id => company.id, :role_id => 2 })
		t = Thread::new {
			ShrezMailer.common_mail(params[:email], "Shirezu: invitation to \""+company.name.to_s+"\" company from Global Administrator", "Hello, new user! Welcome to Shirezu.com. You've been invited as Company Administrator. Please register at www.shirezu.com/users/sign_up entering the following invite code (without spaces): " + invite_code).deliver		
		}
		t.run
		message << "ok"

    else
      message <<  ('unknown action')
    end
    unless (company && company.errors).blank?
      render :json => [false,message]
    else
      render :json => [true,message]
    end
  end

  def index
    index_columns ||= [:id,:name,:description]
    current_page = params[:page] ? params[:page].to_i : 1
    rows_per_page = params[:rows] ? params[:rows].to_i : 10

    conditions={:page => current_page, :per_page => rows_per_page}
    conditions[:order] = params["sidx"] + " " + params["sord"] unless (params[:sidx].blank? || params[:sord].blank?)
    
    if params[:_search] == "true"
      conditions[:conditions]=filter_by_conditions(index_columns)
    end

    @resources=Company.paginate(conditions)

    total_entries=@resources.total_entries

		parsed_json = ActiveSupport::JSON.decode(@resources.to_jqgrid_json(index_columns, current_page, rows_per_page, total_entries))

    respond_with(@resources) do |format|
			format.json { render :json => ActiveSupport::JSON.encode(parsed_json)}
    end
  end
  
end
