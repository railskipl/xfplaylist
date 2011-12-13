# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  # config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  
  config.include Devise::TestHelpers, :type => :controller
  

  def valid_address(attributes = {})
    {
      :first_name => 'John',
      :last_name => 'Doe',
      :address1 => '2010 Cherry Ct.',
      :city => 'Mobile',
      :state => 'AL',
      :zip => '36608',
      :country => 'US'
    }.merge(attributes)
  end
  
  def valid_card(attributes = {})
    { :first_name => 'Joe', 
      :last_name => 'Doe',
      :month => 2, 
      :year => Time.now.year + 1, 
      :number => '1', 
      :type => 'bogus', 
      :verification_value => '123' 
    }.merge(attributes)
  end
  
  def valid_user(attributes = {})
    { :name => 'Bubba',
      :password => 'foobar', 
      :password_confirmation => 'foobar',
      :email => "bubba@email.com"
    }.merge(attributes)
  end
  
  def valid_subscription(attributes = {})
    { :plan => subscription_plans(:basic),
      :subscriber => accounts(:localhost)
    }.merge(attributes)
  end

end
