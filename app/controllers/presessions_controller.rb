class PresessionsController < ApplicationController
  def new
  end

  def create
    @user = User.where(:email => params[:user][:email]).first

    if @user
      subdomain = @user.account.full_domain.split(".").first
      redirect_to new_user_session_url(:subdomain => subdomain, :email => @user.email)
    else
      redirect_to signin_path, :alert => "Invalid email."
    end
  end
end
