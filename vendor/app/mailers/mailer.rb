class Mailer < ActionMailer::Base
  default :to => "xfplaylist@gmail.com"

  def contact_email(attributes)
    @attributes = attributes

    settings = {
      :from => "#{attributes[:sender_name]} <#{attributes[:sender_email]}>",
      :subject => "Message from #{attributes[:sender_name]}",
      :reply_to => attributes[:sender_email]
    }

    mail(settings) do |format|
      format.text
    end
  end
end
