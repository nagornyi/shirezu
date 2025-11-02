class ConfirmationsController < ApplicationController
	before_filter :authenticate_user!
	authorize_resource :confirmation
	respond_to :html,:json

	protect_from_forgery :except => [:post_data]

def post_data
	message=""

case params[:oper]
	when 'add'
		params[:id] = "_empty"
		code = [Array.new(6){rand(256).chr}.join].pack("m").chomp
		confirmation = Confirmation.create({ :id => params[:id], :email => params[:email], :company_id => params[:company_id], :project_id => params[:project_id], :role_id => params[:role_id], :code => code })
		if confirmation.errors.empty?
			message << ('ok')
		else
			message << ("Unable to create a confirmation.")
		end
		
	when 'del'
		Confirmation.destroy_all(:id => params[:id].split(","))
		message <<  ('ok')
	
	when 'sort'
		confirmations = Confirmation.all
		confirmations.each do |confirmation|
		confirmation.position = params['ids'].index(confirmation.id.to_s) + 1 if params['ids'].index(confirmation.id.to_s) 
		confirmation.save
		end
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
	index_columns ||= [:id,:email]
	current_page = params[:page] ? params[:page].to_i : 1
	rows_per_page = params[:rows] ? params[:rows].to_i : 10
	
	conditions={:page => current_page, :per_page => rows_per_page}
	conditions[:order] = params["sidx"] + " " + params["sord"] unless (params[:sidx].blank? || params[:sord].blank?)
	
	if params[:_search] == "true"
		conditions[:conditions]=filter_by_conditions(index_columns)
	end
	
	@confirmations=Confirmation.paginate(conditions)
	
	total_entries=@confirmations.total_entries
	
	parsed_json = ActiveSupport::JSON.decode(@confirmations.to_jqgrid_json(index_columns, current_page, rows_per_page, total_entries))
	
	respond_with(@confirmations) do |format|
		format.json { render :json => ActiveSupport::JSON.encode(parsed_json)}
	end
end

end
