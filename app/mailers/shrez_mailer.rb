class ShrezMailer < ActionMailer::Base
  default :from => "admin@mydomain.com"

  def common_mail(email, subj, message)
    mail(:to => email, :subject => subj, :body => message)
  end

  def notification_mail(email, fresname)
    @fresname = fresname
    mail(:to => email, :subject => "Shirezu: resource is released")
  end
    
end
