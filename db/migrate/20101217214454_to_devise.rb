class ToDevise < ActiveRecord::Migration
  def self.up
    rename_column :users, :crypted_password, :encrypted_password
    
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :timestamp
    add_column :users, :confirmation_sent_at, :timestamp
    execute "UPDATE users SET confirmed_at = created_at, confirmation_sent_at = created_at"
    add_column :users, :reset_password_token, :string
    add_column :users, :remember_token, :string
    add_column :users, :remember_created_at, :timestamp
    
    rename_column :users, :current_login_at, :current_sign_in_at
    rename_column :users, :last_login_at, :last_sign_in_at
    rename_column :users, :current_login_ip, :current_sign_in_ip
    rename_column :users, :last_login_ip, :last_sign_in_ip

    add_column :users, :sign_in_count, :integer, :default => 0
    add_column :users, :failed_attempts, :integer, :default => 0
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :timestamp

    remove_column :users, :persistence_token
    remove_column :users, :perishable_token
    remove_column :users, :single_access_token

    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :unlock_token,         :unique => true
    
    
    create_table(:admins) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable

      t.timestamps
    end

    add_index :admins, :email,                :unique => true
    add_index :admins, :reset_password_token, :unique => true
    # add_index :admins, :confirmation_token,   :unique => true
    # add_index :admins, :unlock_token,         :unique => true
  end

  def self.down
    remove_index :users, :unlock_token
    remove_index :users, :reset_password_token
    remove_index :users, :confirmation_token

    add_column :users, :single_access_token
    add_column :users, :perishable_token
    add_column :users, :persistence_token

    remove_column :users, :locked_at, :timestamp
    remove_column :users, :unlock_token, :string
    remove_column :users, :failed_attempts
    remove_column :users, :sign_in_count

    rename_column :users, :last_sign_in_ip, :last_login_ip
    rename_column :users, :current_sign_in_ip, :current_login_ip
    rename_column :users, :last_sign_in_at, :last_login_at
    rename_column :users, :current_sign_in_at, :current_login_at

    remove_column :users, :remember_created_at, :timestamp
    remove_column :users, :remember_token, :string
    remove_column :users, :reset_password_token, :string
    remove_column :users, :confirmation_sent_at, :timestamp
    remove_column :users, :confirmed_at, :timestamp
    remove_column :users, :confirmation_token, :string

    rename_column :users, :encrypted_password, :crypted_password

    drop_table :admins
  end
end
