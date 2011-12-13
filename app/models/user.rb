class User < ActiveRecord::Base
  belongs_to :account

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :registerable and :timeoutable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:email, :account_id]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_protected :account_id

end
