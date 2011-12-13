require 'ostruct'

begin
require 'extensions/active_merchant'
rescue NameError
  puts "Error with SaaS plugin: ActiveMerchant is missing.  Please add it to your Gemfile and run 'bundle install'.\n\n"
end

module Saas
  Config = OpenStruct.new

  module Base
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end
  end
  
  module ClassMethods
    # The limits hash is used to add some methods to the class that you can
    # use to check whether the subscriber has the rights to do something.  
    # The hash keys match the *_limit fields in the subscriptions and
    # subscription_plan tables, and the values are the methods that will be
    # called to see if that limit has been reached.  For example,
    # 
    # { 'user_limit' => Proc.new {|a| a.users.count } }
    # 
    # defines a single limit based on the user_limit attribute that would
    # call users.account on the instance of the model that is invoking this
    # method.  In other words, if you have this:
    # 
    # class Account < ActiveRecord::Base
    #   has_subscription({ 'user_limit' => Proc.new {|a| a.users.count } })
    # end
    # 
    # then you could call @account.reached_user_limit? to know whether to allow
    # the account to create another user.    
    def has_subscription(limits = {})
      has_one :subscription, :dependent => :destroy, :as => :subscriber
      has_many :subscription_payments, :as => :subscriber

      accepts_nested_attributes_for :subscription

      validate :valid_plan?, :on => :create
      validate :valid_payment_info?, :on => :create
      validate :valid_subscription?, :on => :create

      send(:include, InstanceMethods)

      attr_accessible :plan, :plan_start, :creditcard, :address
      attr_accessor :plan, :plan_start, :creditcard, :address, :affiliate

      after_create :send_welcome_email

      write_inheritable_attribute(:subscription_limits, limits)
      
      # Create methods for each limit for checking the limit.
      # E.g., for a field user_limit, this will define reached_user_limit?
      limits.each do |name, meth|
        define_method("reached_#{name}?") do
          return false unless self.subscription
          # A nil value will always return false, or, in other words, nil == unlimited
          subscription.send(name) && subscription.send(name) <= meth.call(self)
        end
      end
    end
  end

  module InstanceMethods
    def home_url(path = nil)
      "http://#{ [(respond_to?(:full_domain) ? full_domain : Saas::Config.base_domain), path].compact.join("/") }"
    end

    # Does the account qualify for a particular subscription plan
    # based on the plan's limits
    def qualifies_for?(plan)
      self.class.read_inheritable_attribute(:subscription_limits).map do |name, meth|
        limit = plan.send(name) 
        !limit || (meth.call(self) <= limit)
      end.all?
    end
  
    def needs_payment_info?
      if new_record?
        Saas::Config.require_payment_info_for_trials && @plan && @plan.amount.to_f + @plan.setup_amount.to_f > 0
      else
        self.subscription.needs_payment_info?
      end
    end

    def active?
      subscription.current?
    end
    
    protected
    
      def valid_payment_info?
        if needs_payment_info?
          unless @creditcard && @creditcard.valid?
            errors.add(:base, "Invalid payment information")
          end

          unless @address && @address.valid?
            errors.add(:base, "Invalid address")
          end
        end
      end

      def valid_plan?
        errors.add(:base, "Invalid plan selected.") unless @plan
      end

      def valid_subscription?
        return if errors.any? # Don't bother with a subscription if there are errors already
        self.build_subscription(:plan => @plan, :next_renewal_at => @plan_start, :creditcard => @creditcard, :address => @address, :affiliate => @affiliate)
        if !subscription.valid?
          errors.add(:base, "Error with payment: #{subscription.errors.full_messages.to_sentence}")
          return false
        end
      end
    
      def send_welcome_email
        SubscriptionNotifier.welcome(self).deliver
      end

  end

  module ControllerHelpers
    def self.included(base)
      base.inherit_resources
      base.before_filter :authenticate_saas_admin!
    end
  end
  
  module AppControllerStuff
    # Set up some stuff for ApplicationController
    def self.included(base)
      base.send :before_filter, :set_affiliate_cookie
      base.send :before_filter, :set_mailer_url_options
      base.send :helper_method, :current_account, :admin?
    end

    protected

      # This is used throughout the app to scope queries, like
      # current_account.users, etc.
      def current_account(raise_on_not_found = true)
        @current_account ||= Account.find_by_full_domain(request.host) || (Rails.env.development? ? Account.first : nil)
        raise ActiveRecord::RecordNotFound if !@current_account && raise_on_not_found
        @current_account
      end

      # Whether a user is the admin for the account loaded by the
      # current subdomain
      def admin?
        user_signed_in? && current_user.admin?
      end

      def set_affiliate_cookie
        if !params[:ref].blank? && affiliate = SubscriptionAffiliate.find_by_token(params[:ref])
          cookies[:affiliate] = { :value => params[:ref], :expires => 1.month.from_now }
        end
      end

      def set_mailer_url_options
        ActionMailer::Base.default_url_options[:host] = current_account(false).try(:full_domain)
      end
  end
end

ActiveRecord::Base.send :include, Saas::Base
ActionController::Base.send :include, Saas::AppControllerStuff

begin
  YAML::load_file(config_file = Rails.root.join('config', 'saas.yml'))[Rails.env].each do |k, v|
    Saas::Config.send("#{k}=", v)
  end
  Rails.application.config.action_mailer.default_url_options = { :host => Saas::Config.base_domain }
rescue
  puts "Error with SaaS plugin: The config file #{config_file} is missing.  Please run 'rails generate saas' to generate one and generate the migrations.\n\n"
end