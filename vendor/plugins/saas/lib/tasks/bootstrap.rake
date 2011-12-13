require 'rails/generators'

namespace :saas do
  desc 'Load an initial set of data'
  task :bootstrap => :environment do
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    
    Rails::Generators.invoke('saas')
    
    # We probably didn't have a saas.yml before now, so let's make
    # sure we populate some needed info
    Saas::Config.base_domain ||= 'subscriptions.dev'
    
    if SubscriptionPlan.count == 0
      plans = [
        { 'name' => 'Free', 'amount' => 0, 'user_limit' => 2 },
        { 'name' => 'Basic', 'amount' => 10, 'user_limit' => 5 },
        { 'name' => 'Premium', 'amount' => 30, 'user_limit' => nil }
      ].collect do |plan|
        SubscriptionPlan.create(plan)
      end
    end

    account = Account.create(:name => 'Test Account', :domain => 'test', :plan => SubscriptionPlan.first, :admin_attributes => { :name => 'Test', :password => 'tester', :password_confirmation => 'tester', :email => 'test@example.com' })
    SaasAdmin.create(:email => 'admin@example.com', :password => 'password', :password_confirmation => 'password')

    puts <<-EOF

      All done! 
      
      If you're using Pow (http://pow.cx) (and you really should),
      and you link this path to ~/.pow/subscriptions, you can now
      login to the test account at http://#{account.full_domain}
      with the email test@example.com and password tester. 
      
      You can also login to the admin at
      http://#{Saas::Config.base_domain}/saas_admin with the
      email admin@example.com and password password.
      
      Finally, you can view your site's homepage at
      http://#{Saas::Config.base_domain}/

    EOF
  end
end
