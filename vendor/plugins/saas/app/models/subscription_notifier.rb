class SubscriptionNotifier < ActionMailer::Base
  include ActionView::Helpers::NumberHelper
  
  def setup_email(to, subject, from = Saas::Config.from_email)
    @sent_on = Time.now
    @subject = subject
    @recipients = to.respond_to?(:email) ? to.email : to
    @from = from.respond_to?(:email) ? from.email : from
  end

  def setup_environment(obj)
    if obj.is_a?(SubscriptionPayment)
      @subscription = obj.subscription
      @amount = obj.amount
    elsif obj.is_a?(Subscription)
      @subscription = obj
    end
    @subscriber = @subscription.subscriber
  end
  
  def welcome(account)
    setup_email(account.admin, "Welcome to #{Saas::Config.app_name}!")
    @subscriber = account
  end
  
  def trial_expiring(subscription)
    setup_environment(subscription)
    setup_email(@subscriber, 'Trial period expiring')
  end
  
  def charge_receipt(subscription_payment)
    setup_environment(subscription_payment)
    setup_email(@subscriber, "Your #{Saas::Config.app_name} invoice")
  end
  
  def setup_receipt(subscription_payment)
    setup_environment(subscription_payment)
    setup_email(@subscriber, "Your #{Saas::Config.app_name} invoice")
  end
  
  def misc_receipt(subscription_payment)
    setup_environment(subscription_payment)
    setup_email(@subscriber, "Your #{Saas::Config.app_name} invoice")
  end
  
  def charge_failure(subscription)
    setup_environment(subscription)
    setup_email(subscription.subscriber, "Your #{Saas::Config.app_name} renewal failed")
    @bcc = Saas::Config.from_email
  end
  
  def plan_changed(subscription)
    setup_environment(subscription)
    setup_email(subscription.subscriber, "Your #{Saas::Config.app_name} plan has been changed")
  end
end
