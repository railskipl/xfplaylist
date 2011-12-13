class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login, :null => false
      t.string :name
      t.string :email, :null => false
      t.string :crypted_password, :null => false
      t.string :password_salt, :null => false
      t.string :persistence_token, :null => false
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.string :last_login_ip
      t.string :current_login_ip
      t.string :single_access_token
      t.integer :account_id
      t.boolean :admin, :default => false
      t.timestamps
    end
    
    add_index :users, :login
    add_index :users, :email
    add_index :users, :persistence_token
    add_index :users, :single_access_token, :unique => true
    add_index :users, :account_id
  end

  def self.down
    drop_table :users
  end
end
