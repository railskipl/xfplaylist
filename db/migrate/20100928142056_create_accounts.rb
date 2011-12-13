class CreateAccounts < ActiveRecord::Migration
  def self.up

    create_table "accounts", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "full_domain"
      t.datetime "deleted_at"
    end

    add_index "accounts", "full_domain"

  end

  def self.down
    drop_table :accounts
  end
end
