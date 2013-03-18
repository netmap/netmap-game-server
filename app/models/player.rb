# A user's identity in the game.
class Player < ActiveRecord::Base
  # The player is known by this to everyone else in the game.
  validates :name, length: 1..20, uniqueness: true

  # The user that owns this player.
  belongs_to :user, inverse_of: :player
  validates :user, presence: true
  validates :user_id, uniqueness: true

  # The player's faction.
  validates :faction, inclusion: { in: [0, 1, 2] }

  # Sets this player up to represent the given user.
  #
  # @param {User} owner the user who will control this player
  def bootstrap_for(owner)
    self.user = owner
    self.level = 1
  end
end
