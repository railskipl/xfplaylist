class HomeController < ApplicationController
  
 
  
  def about
    @page = Page.find(params[:id])
  end
end
