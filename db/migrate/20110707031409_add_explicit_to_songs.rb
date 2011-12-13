class AddExplicitToSongs < ActiveRecord::Migration
  def self.up
    add_column :songs, :explicit, :boolean, :default => false
  end

  def self.down
    remove_column :songs, :explicit
  end
end
