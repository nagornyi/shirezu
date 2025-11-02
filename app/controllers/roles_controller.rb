class RolesController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource
	respond_to :html,:json

	protect_from_forgery :except => [:post_data]

  def post_data
    message=""
    resource_params = { :id => params[:id],:name => params[:name] }
    case params[:oper]

    when 'add'

    when 'edit'

    when 'del'

    when 'sort'
      roles = Role.all
      roles.each do |role|
        role.position = params['ids'].index(role.id.to_s) + 1 if params['ids'].index(role.id.to_s) 
        role.save
      end
      message << "sort ak"

    else
      message <<  ('unknown action')
    end
    unless (role && role.errors).blank?  
      role.errors.entries.each do |error|
        message << "<strong>#{Role.human_attribute_name(error[0])}</strong> : #{error[1]}<br/>"
      end
      render :json =>[false,message]
    else
      render :json => [true,message] 
    end
  end

  def index
    index_columns ||= [:id,:name]
    current_page = params[:page] ? params[:page].to_i : 1
    rows_per_page = params[:rows] ? params[:rows].to_i : 10

    conditions={:page => current_page, :per_page => rows_per_page}
    conditions[:order] = params["sidx"] + " " + params["sord"] unless (params[:sidx].blank? || params[:sord].blank?)
    
    if params[:_search] == "true"
      conditions[:conditions]=filter_by_conditions(index_columns)
    end
    
    @roles=Role.paginate(conditions)
    total_entries=@roles.total_entries
    
    respond_with(@roles) do |format|
      format.json { render :json => @roles.to_jqgrid_json(index_columns, current_page, rows_per_page, total_entries)}  
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        format.html { redirect_to(@role, :notice => 'Role was successfully created.') }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])

    respond_to do |format|
      if @role.update_attributes(params[:role])
        format.html { redirect_to(@role, :notice => 'Role was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end
end
