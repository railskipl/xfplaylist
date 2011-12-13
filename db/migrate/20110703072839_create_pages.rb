class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :title, :null => false
      t.string :slug,  :null => false
      t.text   :body
      t.integer :position
      t.timestamps
    end

    add_index :pages, :slug, :unique => true
  end

  def self.down
    drop_table :pages
  end
end
