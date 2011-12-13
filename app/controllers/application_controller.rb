class ApplicationController < ActionController::Base
  include UrlHelper

  protect_from_forgery

  before_filter :find_navigation

  protected

  def find_navigation
    @navigation = Page.all
  end
end
