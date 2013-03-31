module UserFilters
  extend ActiveSupport::Concern

  included do
    authenticates_using_session
  end

  # before_filter that only lets registered users through.
  def ensure_user_logged_in
  end

  # before_filter that only
  def ensure_player_logged_in
    return bounce_user unless current_user
    unless current_user.player
      redirect_to :new_player_url
    end
  end

  # before_filter that only lets admins through.
  def ensure_user_is_admin
    bounce_user unless current_user and current_user.admin?
  end
end
