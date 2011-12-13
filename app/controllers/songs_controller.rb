class SaasAdmin::SongsController < ApplicationController
  include Saas::ControllerHelpers

  def create
    create! { saas_admin_songs_url }
  end

  def update
    update! { edit_saas_admin_song_url(@song) }
  end
end
