class RenameAdminTable < ActiveRecord::Migration
  def self.up
    rename_table :admins, :saas_admins
  end

  def self.down
    rename_table :saas_admins, :admins
  end
end
