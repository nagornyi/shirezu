class HelpersController < ApplicationController
	before_filter :authenticate_user!
	authorize_resource :helper
	respond_to :html,:json

	protect_from_forgery :except => [:post_data]

  def post_data
    message=""

    case params[:oper]

		when 'get_time_zones'
			curtz = Profile.find(@current_user.profile_id).read_attribute(:time_zone).to_s
			tz = "<select id=\"usrTimeZone\" name=\"usrTimeZone\">"
			TZInfo::Timezone.all_identifiers.each do |zone|
				if zone.to_s == curtz
					tz = tz + "<option value=\"#{zone}\" selected=\"selected\">#{zone}<\/option>"	
				else			
					tz = tz + "<option value=\"#{zone}\">#{zone}<\/option>"
				end
			end
			tz = tz + "<\/select>"
			message << (tz)

		when 'get_data'
			curtz = Profile.find(@current_user.profile_id).read_attribute(:time_zone).to_s
			tz = "<select id=\"usrTimeZone\" name=\"usrTimeZone\">"
			TZInfo::Timezone.all_identifiers.each do |zone|
				if zone.to_s == curtz
					tz = tz + "<option value=\"#{zone}\" selected=\"selected\">#{zone}<\/option>"	
				else			
					tz = tz + "<option value=\"#{zone}\">#{zone}<\/option>"
				end
			end
			tz = tz + "<\/select>"
			message << (tz)
      compName = Company.find(@current_user.company_id).read_attribute(:name).to_s
      message << (','+compName)

		when 'edit_profile'
			profile = Profile.find(@current_user.profile_id)
			message << ('ok') if profile.update_attribute(:time_zone, params[:time_zone])

		when 'edit_profile_as_comp_admin'
			profile = Profile.find(@current_user.profile_id)
      company = Company.find(@current_user.company_id)
			message << ('ok') if profile.update_attribute(:time_zone, params[:time_zone]) and company.update_attribute(:name, params[:comp_name])
      
    else
      message <<  ('unknown action')

    end
		render :json => [true,message]
  end
  
end
