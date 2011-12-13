namespace :saas do
  desc 'Daily task that will bill users and handle trial subscriptions'
  task :run_billing => :environment do

    # Ensures that an exception doesn't kill the entire billing process
    # Thanks, expens'd! :)
    def exception_catcher
      begin
        yield
      rescue Exception => err
        Rails.logger.error("\nException in saas billing: \n#{err.message}\n\t#{err.backtrace.join("\n\t")}\n")
      end
    end

    Subscription.find_expiring_trials.each do |sub|
      exception_catcher { SubscriptionNotifier.deliver_trial_expiring(sub) }
    end

    # Trial subscriptions for which we have payment info.
    # This will always turn up empty unless we are collecting 
    # payment info when creating an account.
    Subscription.find_due_trials.each do |sub|
      exception_catcher { SubscriptionNotifier.deliver_charge_failure(sub) unless sub.charge }
    end

    # Charge due subscriptions
    Subscription.find_due.each do |sub|
      exception_catcher { SubscriptionNotifier.deliver_charge_failure(sub) unless sub.charge }
    end

    # Subscriptions overdue for payment (2nd try)
    Subscription.find_due(5.days.ago).each do |sub|
      exception_catcher { SubscriptionNotifier.deliver_charge_failure(sub) unless sub.charge }
    end
  end
end