class ExtRegistrationsController < Devise::RegistrationsController
  #prepend_view_path "app/views/devise"

  def new
    super
  end

  def create
      if verify_recaptcha
        super
      else
        build_resource
        clean_up_passwords(resource)
        flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."      
        flash.delete :recaptcha_error
        render :new
      end
	if @user.read_attribute(:id)!=nil
		profile = Profile.create(params[:user][:profile])
		user = User.find(@user.read_attribute(:id))
		user.update_attribute(:profile_id, profile.read_attribute(:id))
		confirmation = Confirmation.where(:email => user.read_attribute(:email)).first
		if !confirmation.blank?
			user.update_attribute(:company_id, confirmation.read_attribute(:company_id)) if confirmation.read_attribute(:company_id)!=nil and confirmation.read_attribute(:company_id)!=''
			user.update_attribute(:project_id, confirmation.read_attribute(:project_id)) if confirmation.read_attribute(:project_id)!=nil and confirmation.read_attribute(:project_id)!=''			 
			confirmation.destroy
		end
	end	
  end

  def update
    super
  end
end
