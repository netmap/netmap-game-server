# Numbers describing a player that change quickly.
#
# For example, the player's experience (xp) changes every time the player
# interacts with the game universe.
class PlayerStats < ActiveRecord::Base
  # The player whose stats these are.
  belongs_to :player, inverse_of: :stats

  # The player's experience, which decides their level.
  validates :xp, presence: true, numericality: { above_or_equal_to: 0 }

  # The player's magic energy level, which decides what spells they can cast.
  validates :mana, presence: true, numericality: { above_or_equal_to: 0 }
end
