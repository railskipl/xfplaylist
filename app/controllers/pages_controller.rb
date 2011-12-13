class PagesController < ApplicationController
  skip_before_filter :authenticate_user!
  
  def show
    @page = Page.find(params[:id])
  end
end
