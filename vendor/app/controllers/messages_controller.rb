class MessagesController < ApplicationController
  skip_before_filter :authenticate_user!

  def new
  end

  def create
    if valid_message?(params[:message])
      Mailer.contact_email(params[:message]).deliver
      redirect_to sent_url(:subdomain => false)
    else
      render :action => "new"
    end
  end

  def sent
  end

  protected

  def valid_message?(message)
    return false if message[:title].present?

    [:sender_name, :sender_email, :body].each do |attr|
      return false if message[attr].blank?
    end

    return false unless message[:sender_email].match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)
    
    true
  end
end
