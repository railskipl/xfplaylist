class SaasAdmin::SubscriptionsController < ApplicationController
  include Saas::ControllerHelpers

  def index
    @stats = SubscriptionPayment.stats if params[:page].blank?
    @subscriptions = Subscription.paginate(:include => :subscriber, :page => params[:page], :per_page => 30)
  end
  
  def charge
    if request.post? && !params[:amount].blank?
      if resource.misc_charge(params[:amount])
        flash[:notice] = 'The card has been charged.'
        redirect_to :action => "show"
      else
        render :action => 'show'
      end
    end
  end
  
end
