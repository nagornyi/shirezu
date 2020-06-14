class ProfilesController < ApplicationController
	before_filter :authenticate_profile!
	load_and_authorize_resource
	respond_to :html,:json

	protect_from_forgery :except => [:post_data]

  def post_data
    message=""
    resource_params = { :id => params[:id],:time_zone => params[:time_zone] }
    case params[:oper]

    when 'add'

    when 'edit'

    when 'del'
      Profile.destroy_all(:id => params[:id].split(","))
      message <<  ('ok')

    when 'sort'
      profiles = Profile.all
      profiles.each do |profile|
        profile.position = params['ids'].index(profile.id.to_s) + 1 if params['ids'].index(profile.id.to_s) 
        profile.save
      end
      message << "ok"

    else
      message <<  ('unknown action')
    end
    unless (profile && profile.errors).blank?  
      user.errors.entries.each do |error|
        message << "<strong>#{Profile.human_attribute_name(error[0])}</strong> : #{error[1]}<br/>"
      end
      render :json =>[false,message]
    else
      render :json => [true,message] 
    end
  end

  def index
    index_columns ||= [:id,:time_zone]
    current_page = params[:page] ? params[:page].to_i : 1
    rows_per_page = params[:rows] ? params[:rows].to_i : 10

    conditions={:page => current_page, :per_page => rows_per_page}
    conditions[:order] = params["sidx"] + " " + params["sord"] unless (params[:sidx].blank? || params[:sord].blank?)
    
    if params[:_search] == "true"
      conditions[:conditions]=filter_by_conditions(index_columns)
    end
    
    @profiles=Profile.paginate(conditions)
    total_entries=@profiles.total_entries
    
    respond_with(@profiles) do |format|
      format.json { render :json => @profiles.to_jqgrid_json(index_columns, current_page, rows_per_page, total_entries)}  
    end
  end

  def new
    @profile = Profile.new
    @current_method = "new"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  def edit
    @profile = Profile.find(params[:id])
  end

  def create
    @profile = Profile.new(params[:profile])

    respond_to do |format|
      if @profile.save
		    format.html { redirect_to(profiles_url) }
		    format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @profile = Profile.find(params[:id])

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
		    format.html { redirect_to(profiles_url) }
		    format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to(profiles_url) }
      format.xml  { head :ok }
    end
  end

end
