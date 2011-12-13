class Page < ActiveRecord::Base
  acts_as_list

  default_scope order("position ASC, title ASC")

  attr_accessible :title, :slug, :body

  validates :title, :presence => true
  validates :slug,  :presence => true, :uniqueness => true, :format => /[\w-]+/

  before_validation :set_slug_if_necessary

  def body_html
    RDiscount.new(body || "").to_html
  end

  protected

  def set_slug_if_necessary
    if title.present? && slug.blank?
      new_slug = title.downcase
      new_slug.gsub!(/\W/, "-")    # Replace each non-letter, non-digit, and non-underscore with a dash
      new_slug.gsub!(/-{2,}/, "-") # Replace sequences of dashes with a single dash
      new_slug.gsub!(/-\z/, "")    # Strip trailing slash
      self.slug = new_slug
    end
  end
end
