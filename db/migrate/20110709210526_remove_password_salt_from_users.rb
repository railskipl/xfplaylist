class RemovePasswordSaltFromUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.remove :password_salt
    end
  end

  def self.down
    change_table :users do |t|
      t.string :password_salt, :null => false
    end
  end
end
