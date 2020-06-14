module DeviseHelper
	
	# handling devise error messages in a popup
  def devise_error_messages!
    flash_alerts = []
    error_key = 'errors.messages.not_saved'

    if !flash.empty?
      flash_alerts.push(flash[:error]) if flash[:error]
      flash_alerts.push(flash[:alert]) if flash[:alert]
      flash_alerts.push(flash[:notice]) if flash[:notice]
      error_key = 'devise.failure.invalid'
    end

    return "" if resource.errors.empty? && flash_alerts.empty?
    errors = resource.errors.empty? ? flash_alerts : resource.errors.full_messages

    messages = errors.map { |msg| content_tag(:div, msg) }.join
		return "" if messages=="<div></div>"
    sentence = I18n.t(error_key, :count    => errors.count,
                                 :resource => resource.class.model_name.human.downcase)

	return "" if messages.include? "Signed out successfully."
    html = <<-HTML
		<script type="text/javascript">
		$.prompt("<div class='errornotice'>Warning<\/div>#{messages}");
		</script>
    HTML

    html.html_safe
  end

end

