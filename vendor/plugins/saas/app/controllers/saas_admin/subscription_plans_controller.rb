class SaasAdmin::SubscriptionPlansController < ApplicationController
  include Saas::ControllerHelpers

  protected
  
    def resource
      @subscription_plan ||= SubscriptionPlan.find_by_name!(params[:id])
    end
end
