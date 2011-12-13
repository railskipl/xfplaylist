class SaasAdmin::PagesController < ApplicationController
  include Saas::ControllerHelpers

  def create
    @page = Page.new(params[:page])
    @page.position = (Page.maximum(:position) || 0) + 1
    create!
  end

  def update
    update! { edit_saas_admin_page_url(@page) }
  end
  
  def reposition
    @page = Page.find(params[:id])
    
    respond_to do |format|
      if @page.insert_at(params[:position])
        format.js { head :ok }
      else
        format.js { head :unprocessable_entity } # Maybe find a better status code to use.
      end
    end
  end
end
