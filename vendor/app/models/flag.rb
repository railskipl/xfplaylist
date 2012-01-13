class Flag < ActiveRecord::Base
  belongs_to :song
  belongs_to :account
end
