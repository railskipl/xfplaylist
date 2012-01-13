class Post < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 10

  attr_accessible :title, :body

  validates :title, :presence => true

  def body_html
    RDiscount.new(body || "").to_html
  end

  def to_param
    slug = title.downcase
    slug.gsub!(/\W/, "-")    # Replace each non-letter, non-digit, and non-underscore with a dash
    slug.gsub!(/-{2,}/, "-") # Replace sequences of dashes with a single dash
    slug.gsub!(/-\z/, "")    # Strip trailing slash
    "#{id}-#{slug}"
  end
end
