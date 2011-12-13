class SaasAdmin::SongsController < ApplicationController
  

  def create
    create! { saas_admin_songs_url }
  end

  def update
    update! { edit_saas_admin_song_url(@song) }
  end
end
