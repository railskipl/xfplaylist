class Song < ActiveRecord::Base
  GENRES = ["Rock", "Hardcore Rock", "R&B/Hip-Hop", "Country", "Electric"]
  
  has_many :flags, :dependent => :destroy
  has_many :accounts, :through => :flags
  
  default_scope order("genre ASC, title ASC")
  
  attr_accessible :url, :title, :video_id, :seconds, :genre, :explicit

  before_validation :populate_fields

  validates :title,    :presence => true
  validates :video_id, :presence => true, :uniqueness => true
  validates :seconds,  :presence => true, :numericality => true
  validates :genre, :presence => true, :inclusion => { :in => GENRES }
  
  scope :not_flagged_by_account, lambda { |user|
      Song.where(Song.arel_table[:id].not_in(Flag.arel_table.project(:song_id).where(Flag.arel_table[:account_id].eq(user.account.id))))
  }
  scope :clean, where(:explicit => false)

  def url=(new_url)
    self.video_id = (a = new_url["?v="]) ? new_url.split("?v=")[1] : new_url.split("/")[-1]
  end

  def url
    video_id ? "http://www.youtube.com/watch?v=#{video_id}" : nil
  end

  protected

  def populate_fields
    if video_id && video_id_changed?
      response = HTTParty.get("http://gdata.youtube.com/feeds/api/videos/#{video_id}?v=2")

      if response.response.code == "200"
        feed = Nokogiri::XML.parse(response.body)
        self.title = feed.xpath("//media:title").text
        self.seconds = feed.xpath("//yt:duration").attribute("seconds").value
        self.flags.each do |flag|
          flag.destroy
        end
      else
        errors[:base] << "Data for this video isn't available yet. Try again in an hour or two."
      end
    end
  end
end
