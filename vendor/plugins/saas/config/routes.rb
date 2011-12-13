Rails.application.routes.draw do

  devise_for :saas_admins

  namespace "saas_admin" do

    root :to => "subscriptions#index"

    resources :subscriptions do
      member do
        post :charge
      end
    end

    resources :accounts
    resources :subscription_plans, :path => 'plans'
    resources :subscription_discounts, :path => 'discounts'
    resources :subscription_affiliates, :path => 'affiliates'
  end

end
