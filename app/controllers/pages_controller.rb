class PagesController < ApplicationController
  skip_before_filter :authenticate_user!
  
  def show
    @page = current_user.pages.find(params[:id])
  end
end
