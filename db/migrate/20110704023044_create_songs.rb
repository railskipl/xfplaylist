class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string  :title,    :null => false
      t.string  :video_id, :null => false
      t.integer :seconds,  :null => false, :default => 0
      t.string  :genre,    :null => false
      t.timestamps
    end

    add_index :songs, :video_id, :unique => true
  end

  def self.down
    drop_table :songs
  end
end
