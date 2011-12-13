class SubscriptionPayment < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :subscriber, :polymorphic => true
  belongs_to :affiliate, :class_name => 'SubscriptionAffiliate', :foreign_key => 'subscription_affiliate_id'
  
  before_create :set_info_from_subscription
  before_create :calculate_affiliate_amount
  after_create :send_receipt
  
  def self.stats
    {
      :last_month => calculate(:sum, :amount, :conditions => { :created_at => (1.month.ago.beginning_of_month .. 1.month.ago.end_of_month) }),
      :this_month => calculate(:sum, :amount, :conditions => { :created_at => (Time.now.beginning_of_month .. Time.now.end_of_month) }),
      :last_30 => calculate(:sum, :amount, :conditions => { :created_at => (1.month.ago .. Time.now) })
    }
  end
  
  protected
  
    def set_info_from_subscription
      self.subscriber = subscription.subscriber
      self.affiliate = subscription.affiliate
    end

    def calculate_affiliate_amount
      return unless affiliate
      self.affiliate_amount = amount * affiliate.rate
    end

    def send_receipt
      return unless amount > 0
      if setup?
        SubscriptionNotifier.setup_receipt(self).deliver
      elsif misc?
        SubscriptionNotifier.misc_receipt(self).deliver
      else
        SubscriptionNotifier.charge_receipt(self).deliver
      end
      true
    end

end
